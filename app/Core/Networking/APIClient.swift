import Foundation

protocol APIClienting {
    func send(_ request: APIRequest) async throws -> Data
}

final class APIClient: APIClienting {
    private let baseURL: URL
    private let session: URLSession
    private let tokenStore: AuthTokenStore

    init(
//        baseURL: URL = URL(string: "https://api.whatflix.ai")!,
        baseURL: URL = URL(string: "http://192.168.1.17:8000")!,
        session: URLSession = .shared,
        tokenStore: AuthTokenStore = AuthTokenStore()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStore = tokenStore
    }

    func send(_ request: APIRequest) async throws -> Data {
        do {
            return try await perform(request)
        } catch NetworkError.unauthorized where request.requiresAuth && request.path != "auth/refresh" {
            try await refreshSession()
            return try await perform(request)
        }
    }

    private func perform(_ request: APIRequest) async throws -> Data {
        let urlRequest = try buildURLRequest(for: request)
        print("APIClient -> \(request.method) \(urlRequest.url?.absoluteString ?? request.path)")

        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.requestFailed
        }

        print("APIClient <- status \(httpResponse.statusCode) for \(urlRequest.url?.absoluteString ?? request.path)")

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }

            if let serverError = try? JSONDecoder().decode(APIErrorEnvelope.self, from: data) {
                throw NetworkError.serverError(
                    code: serverError.error.code,
                    message: serverError.error.message
                )
            }

            throw NetworkError.requestFailed
        }

        return data
    }

    private func buildURLRequest(for request: APIRequest) throws -> URLRequest {
        guard let url = URL(string: request.path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        urlRequest.httpBody = request.body
        urlRequest.timeoutInterval = 10.0

        request.headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }

        if request.body != nil && request.headers["Content-Type"] == nil {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if request.requiresAuth, let accessToken = tokenStore.accessToken {
            urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        return urlRequest
    }

    private func refreshSession() async throws {
        guard tokenStore.hasStoredSession,
              let refreshToken = tokenStore.refreshToken(),
              let sessionID = tokenStore.sessionID() else {
            throw NetworkError.unauthorized
        }

        let payload = RefreshRequestPayload(refreshToken: refreshToken, sessionId: sessionID)
        let refreshRequest = try Endpoint.refresh(payload)
        let data = try await perform(refreshRequest)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response: RefreshResponsePayload
        do {
            response = try decoder.decode(RefreshResponsePayload.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }

        tokenStore.updateAccessToken(response.tokens.accessToken)
        tokenStore.updateRefreshToken(response.tokens.refreshToken)
    }
}
