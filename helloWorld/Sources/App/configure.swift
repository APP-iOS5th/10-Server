import Vapor
import Fluent
import FluentSQLiteDriver
import Leaf
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    app.logger.logLevel = .debug
    
    // Add HMAC with SHA-256 signer.
    app.jwt.signers.use(.hs256(key: "your-secret-key"))  // 실제 운영 환경에서는 환경 변수 등을 통해 안전하게 관리해야 합니다.

    // 데이터베이스 드라이버 로드
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // // 세션을 데이터베이스에서 관리하도록 설정
    app.sessions.use(.fluent)
    app.migrations.add(SessionRecord.migration)

    // 마이그레이션 코드 추가
    app.migrations.add(CreateEntry())
    app.migrations.add(CreateAdmin())
    app.migrations.add(CreateAdminUser())

    // 템플릿 엔진 Leaf 추가
    app.views.use(.leaf)

    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)

    // Journal Controller 라우터 등록
    try app.register(collection: JournalController())

    // register routes
    try routes(app)

    let protected = app.grouped(UserAuthenticator())
    protected.get("me") { req -> String in
        try req.auth.require(User.self).name
    }

    
    // 마이그레이션 코드 실행 ( 개발 모드에서만 실행할 것! )
    try await app.autoMigrate().get()
}
