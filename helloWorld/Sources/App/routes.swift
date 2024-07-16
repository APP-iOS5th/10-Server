import Vapor
import Leaf

func routes(_ app: Application) throws {
    
    let sessionMiddleware = app.sessions.middleware
    let authSessionMiddleware = Admin.sessionAuthenticator()
    let guardMiddleware = Admin.redirectMiddleware(path: "/login")
    
    let protected = app.grouped(sessionMiddleware, authSessionMiddleware, guardMiddleware)
    
    try app.register(collection: PublicRoutes())
    try protected.register(collection: ProtectedRoutes())

    app.get { req async in
        "It works!"
    }

    app.get("hello") { req -> EventLoopFuture<View> in
        req.logger.info("Received request for /hello")
        return req.view.render("hello", ["name": "Leaf"])
    }
    
    app.get("greet", ":name") { req async -> String in
        guard let guest = req.parameters.get("name") else {
            return "Hi!"
        }
        return "Hi, \(guest), greetings! Thanks for visiting us."
    }

    app.get("student", ":name") { req async throws -> String in
        guard let studentName = req.parameters.get("name") else {
            throw Abort(.badRequest)
        }
        let studentRecords =  [
            "Peter" : 3.42,
            "Thomas" : 2.98,
            "Jane" : 3.91,
            "Ryan" : 4.00,
            "Kyle" : 4.00
        ]
        if let gpa = studentRecords[studentName] {
            return "The student \(studentName)'s GPA is \(gpa)"
        } else {
            return "The student's record can't be found!"
        }
    }
}
