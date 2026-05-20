import Foundation
import AuthenticationServices

public final class AuthManager: NSObject, ObservableObject {
    public static let shared = AuthManager()
    @Published public var accessToken: String?
    @Published public var refreshToken: String?
    @Published public var idToken: String?

    private override init() {}

    public func signIn(issuer: URL, clientId: String, redirectURI: URL, scopes: [String] = ["openid","profile","email"]) {
        // Placeholder for AppAuth integration.
    }

    public func signOut() {
        accessToken = nil; refreshToken = nil; idToken = nil
    }
}
