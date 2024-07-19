import Vapor
import JWT

struct AppleJWTPayload: JWTPayload {
    let iss: IssuerClaim
    let iat: IssuedAtClaim
    let exp: ExpirationClaim
    let aud: AudienceClaim
    let sub: SubjectClaim

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}