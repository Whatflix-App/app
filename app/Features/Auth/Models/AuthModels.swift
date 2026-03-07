import Foundation

struct DevicePayload: Codable {
    let id: String
    let platform: String
    let appVersion: String
}

struct AppleLoginRequest: Codable {
    let provider: String
    let identityToken: String
    let authorizationCode: String
    let device: DevicePayload
}

struct AuthUserPayload: Codable {
    let id: String
    let email: String?
    let displayName: String?
    let authProvider: String
}

struct AuthTokensPayload: Codable {
    let accessToken: String
    let accessTokenExpiresAt: Date
    let refreshToken: String
    let refreshTokenExpiresAt: Date
}

struct AuthSessionPayload: Codable {
    let id: String
    let issuedAt: Date
}

struct AuthSuccessResponse: Codable {
    let user: AuthUserPayload
    let tokens: AuthTokensPayload
    let session: AuthSessionPayload
    let isNewUser: Bool
}

struct RefreshRequestPayload: Codable {
    let refreshToken: String
    let sessionId: String
}

struct RefreshResponsePayload: Codable {
    let tokens: AuthTokensPayload
}

struct LogoutRequestPayload: Codable {
    let refreshToken: String
    let sessionId: String
}

struct APIErrorEnvelope: Codable {
    let error: APIErrorPayload
}

struct APIErrorPayload: Codable {
    let code: String
    let message: String
    let retryable: Bool
}
