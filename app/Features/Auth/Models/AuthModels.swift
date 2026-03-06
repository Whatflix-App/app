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

struct AuthSuccessResponse: Codable {
    let user: AuthUserPayload
    let isNewUser: Bool
}

struct APIErrorEnvelope: Codable {
    let error: APIErrorPayload
}

struct APIErrorPayload: Codable {
    let code: String
    let message: String
    let retryable: Bool
}
