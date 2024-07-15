import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    app.get("greet", ":name") { req async -> String in
        guard let guest = req.parameters.get("name") else {
            return "Hi!"
        }
        return "Hi, \(guest), greetings! Thanks for visiting us."
    }
}
