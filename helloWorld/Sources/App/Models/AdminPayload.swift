import Vapor
import JWT

struct AdminPayload: JWTPayload {
    let id: UUID
    let name: String
    let exp: ExpirationClaim

    init(id: UUID, name: String, expiration: Date) {
        self.id = id
        self.name = name
        self.exp = ExpirationClaim(value: expiration)
    }

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}