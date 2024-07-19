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
    
    // Apple Sign In 설정
    try configureAppleSignIn(app)
    
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
    
    // API 라우터 등록
    try app.register(collection: APIRoutes(app: app))
    
    // Apple 로그인 라우터 등록
    try app.register(collection: AppleAuthController(app: app))
    
    // register routes
    try routes(app)
    
    let protected = app.grouped(UserAuthenticator())
    protected.get("me") { req -> String in
        try req.auth.require(User.self).name
    }
    
    // 마이그레이션 코드 실행 ( 개발 모드에서만 실행할 것! )
    try await app.autoMigrate().get()
}

func configureAppleSignIn(_ app: Application) throws {
    app.logger.debug("Starting Apple Sign In configuration")
    
    let privateKeyPath = app.directory.resourcesDirectory + "/Keys/AuthKey.p8"
    let keyID = "W8MZ863T7B"
    let teamID = "59FP2PXRXK"
    let bundleID = "kr.co.codegrove.EntryApp"
    
    guard FileManager.default.fileExists(atPath: privateKeyPath) else {
        app.logger.error("Private key file not found at path: \(privateKeyPath)")
        throw Abort(.internalServerError, reason: "Apple Sign In private key file not found")
    }
    
    let privateKey = try String(contentsOfFile: privateKeyPath)
    let signer = try JWTSigner.es256(key: .private(pem: privateKey))
    
    app.jwt.signers.use(signer, kid: JWKIdentifier(string: keyID))
    
    app.storage[AppleSignInKey.self] = AppleSignInConfig(
        teamID: teamID,
        bundleID: bundleID,
        keyID: keyID
    )
    
    app.logger.notice("Apple Sign In has been configured successfully.")
}

struct AppleSignInConfig {
    let teamID: String
    let bundleID: String
    let keyID: String
}

struct AppleSignInKey: StorageKey {
    typealias Value = AppleSignInConfig
}

