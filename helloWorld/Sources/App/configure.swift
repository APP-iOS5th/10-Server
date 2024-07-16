import Vapor
import Fluent
import FluentSQLiteDriver
import Leaf

// configures your application
public func configure(_ app: Application) async throws {
    app.logger.logLevel = .debug
    
    // 데이터베이스 드라이버 로드
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // 마이그레이션 코드 추가
    app.migrations.add(CreateEntry())
    
    // 템플릿 엔진 Leaf 추가
    app.views.use(.leaf)

    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Journal Controller 라우터 등록
    try app.register(collection: JournalController())

    // register routes
    try routes(app)
    
    // 마이그레이션 코드 실행 ( 개발 모드에서만 실행할 것! )
    try await app.autoMigrate().get()
}
