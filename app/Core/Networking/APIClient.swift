import Foundation

protocol APIClienting {
    func send(_ request: APIRequest) async throws -> Data
}

final class APIClient: APIClienting {
    private let baseURL: URL
    private let session: URLSession

    init(
        baseURL: URL = URL(string: "http://192.168.4.119:8000")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func send(_ request: APIRequest) async throws -> Data {
        guard let url = URL(string: request.path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }

        print("APIClient -> \(request.method) \(url.absoluteString)")

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

        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.requestFailed
        }

        print("APIClient <- status \(httpResponse.statusCode) for \(url.absoluteString)")

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
}
