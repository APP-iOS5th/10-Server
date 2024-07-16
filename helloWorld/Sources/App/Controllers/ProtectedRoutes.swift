//
//  File.swift
//  
//
//  Created by Jungman Bae on 7/16/24.
//

import Vapor

struct ProtectedRoutes: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        routes.get("dashboard", use: dashboardHandler)
        routes.post("logout", use: logoutHandler)
    }
    
    @Sendable
    func dashboardHandler(_ req: Request) throws -> EventLoopFuture<View> {
        guard let user = try? req.auth.require(Admin.self) else {
            throw Abort(.unauthorized)
        }
        return req.view.render("dashboard", ["name": user.name])
    }

    @Sendable
    func logoutHandler(_ req: Request) -> Response {
        req.auth.logout(Admin.self)
        return req.redirect(to: "/login")
    }

}
