import Vapor
import JWT

struct AppleAuthController: RouteCollection {
        let authService: AuthenticationService

    init(app: Application) {
        self.authService = AuthenticationService(app: app)
    }

    func boot(routes: RoutesBuilder) throws {
        let appleAuth = routes.grouped("auth", "apple")
        appleAuth.post(use: handleAppleAuth)
    }

    @Sendable
    func handleAppleAuth(req: Request) async throws -> String {
        let appleAuthPayload = try req.content.decode(AppleAuthPayload.self)
        
        guard let _ = req.application.storage[AppleSignInKey.self] else {
            throw Abort(.internalServerError, reason: "Apple Sign In is not configured")
        }

        req.logger.debug("====================")
        req.logger.debug("\(appleAuthPayload)")
        req.logger.debug("====================")


        // Verify the id_token
        let appleJWT = try req.jwt.verify(appleAuthPayload.id_token, as: AppleIdentityToken.self)

        req.logger.debug("=====\(appleJWT.sub.value)========")

        req.logger.debug("====================")

        let appleID = appleJWT.sub.value

        let admin: Admin

        if let record = try await Admin.query(on: req.db)
            .filter(\Admin.$name, .equal, appleID)
            .first() {
            admin = record
        } else {
            // Create new admin
            admin = Admin(
                name: appleJWT.sub.value,
                passwordHash: "test"
            )
            try await admin.save(on: req.db)
        }

        req.logger.info("Successfully authenticated Apple user with email: \(appleJWT.email ?? "No email")")
        
        let token = try authService.createToken(for: admin)
        return token
    }
}

struct AppleIdentityToken: JWTPayload {
    let iss: IssuerClaim
    let aud: AudienceClaim
    let exp: ExpirationClaim
    let iat: IssuedAtClaim
    let sub: SubjectClaim
    let cHash: String?
    let email: String?
    let emailVerified: String?
    let authTime: Int?
    let nonce: String?

    enum CodingKeys: String, CodingKey {
        case iss, aud, exp, iat, sub
        case cHash = "c_hash"
        case email
        case emailVerified = "email_verified"
        case authTime = "auth_time"
        case nonce
    }

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
