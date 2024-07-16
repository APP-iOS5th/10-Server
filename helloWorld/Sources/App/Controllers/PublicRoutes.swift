//
//  File.swift
//
//
//  Created by Jungman Bae on 7/16/24.
//

import Vapor

struct LoginRequest: Content {
    let name: String
    let password: String
}

struct PublicRoutes: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        routes.get("login", use: loginHandler)
        routes.post("login", use: loginPostHandler)
    }
    
    @Sendable
    func loginHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("login")
    }
    
    @Sendable
    func loginPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let user = try req.content.decode(LoginRequest.self)
        return Admin.query(on: req.db)
            .filter(\Admin.$name, .equal, user.name)
            .first()
            .flatMap { admin in
                guard let admin = admin else {
                    return req.eventLoop.future(req.redirect(to: "/login?error=usernotfound"))
                }
                
                do {
                    let passwordMatches = try admin.verify(password: user.password)
                    if passwordMatches {
                        req.auth.login(admin)
                        req.logger.error("\(admin)!!")
                        return req.eventLoop.future(req.redirect(to: "/dashboard"))
                    } else {
                        return req.eventLoop.future(req.redirect(to: "/login?error=invalidpassword"))
                    }
                } catch {
                    return req.eventLoop.future(req.redirect(to: "/login?error=invalidpassword"))
                }
            }
    }
    
}
