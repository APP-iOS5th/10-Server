import Vapor
import Fluent

struct APIRoutes: RouteCollection {
    let authService: AuthenticationService

    init(app: Application) {
        self.authService = AuthenticationService(app: app)
    }

    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        let authApi = api.grouped(JWTMiddleware())

        // Public routes
        api.post("login", use: login)
        
        // Protected routes
        authApi.get("entries", use: getAllEntries)
        authApi.post("entries", use: createEntry)
        authApi.get("entries", ":entryID", use: getEntry)
        authApi.put("entries", ":entryID", use: updateEntry)
        authApi.delete("entries", ":entryID", use: deleteEntry)

    }

    @Sendable
    func login(req: Request) async throws -> String {
        let loginRequest = try req.content.decode(LoginRequest.self)
        guard let admin = try await Admin.query(on: req.db)
            .filter(\Admin.$name == loginRequest.name)
            .first() else {
            throw Abort(.notFound)
        }
        
        guard try admin.verify(password: loginRequest.password) else {
            throw Abort(.unauthorized)
        }
        
        return try self.authService.createToken(for: admin)
    }

    @Sendable
    func getAllEntries(req: Request) async throws -> [Entry] {
        try await Entry.query(on: req.db).all()
    }

    @Sendable
    func createEntry(req: Request) async throws -> Entry {
        let entry = try req.content.decode(Entry.self)
        try await entry.save(on: req.db)
        return entry
    }

    @Sendable
    func getEntry(req: Request) async throws -> Entry {
        guard let entry = try await Entry.find(req.parameters.get("entryID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return entry
    }

    @Sendable
    func updateEntry(req: Request) async throws -> Entry {
        guard let entry = try await Entry.find(req.parameters.get("entryID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updatedEntry = try req.content.decode(Entry.self)
        entry.title = updatedEntry.title
        entry.content = updatedEntry.content
        try await entry.save(on: req.db)
        return entry
    }

    @Sendable
    func deleteEntry(req: Request) async throws -> HTTPStatus {
        guard let entry = try await Entry.find(req.parameters.get("entryID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await entry.delete(on: req.db)
        return .noContent
    }

}
