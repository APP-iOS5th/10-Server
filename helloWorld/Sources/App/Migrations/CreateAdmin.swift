//
//  File.swift
//  
//
//  Created by Jungman Bae on 7/16/24.
//

import Fluent

struct CreateAdmin: Migration {
    func prepare(on database: any FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("admins")
            .id()
            .field("name", .string, .required)
            .field("password_hash", .string, .required)
            .unique(on: "name")
            .create()
    }
    
    func revert(on database: any FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("admins").delete()
    }
}
