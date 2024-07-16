import Vapor
import JWT

struct JWTMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let token = request.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized)
        }
        
        let payload = try request.jwt.verify(token, as: AdminPayload.self)
        request.auth.login(Admin(id: payload.id, name: payload.name, passwordHash: ""))
        return try await next.respond(to: request)
    }
}
