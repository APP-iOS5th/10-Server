//
//  File.swift
//  
//
//  Created by Jungman Bae on 7/16/24.
//

import Vapor
import Leaf

struct CreateEntryData: Content {
    let title: String
    let content: String
}

struct IndexContext: Encodable {
    let entries: [Entry]
    let count: Int
}

// Entry 모델에 대한 CRUD (Create, Read (Get 1, or List), Update, Delete)
struct JournalController: RouteCollection {
    
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let entries = routes.grouped("entries")
        entries.get(use: index)
        entries.post(use: create)
        entries.get(":id", use: get)
        entries.put(":id", use: update)
        entries.delete(":id", use: delete)
    }

    // List
    @Sendable
    func index(req: Request) async throws -> Response {
        let entries = try await Entry.query(on: req.db).all()
        
        if req.headers.accept.mediaTypes.contains(.html) {
            let context = IndexContext(entries: entries, count: entries.count)
            let view = req.view.render("index", context)
            return try await view.encodeResponse(for: req).get()
        } else {
            return try await entries.encodeResponse(for: req)
        }
    }
//    @Sendable
//    func index(req: Request) throws -> EventLoopFuture<[Entry]> {
//        return Entry.query(on: req.db).all()
//    }
    
    @Sendable
    func create(req: Request) throws -> EventLoopFuture<Entry> {
        req.logger.error("----------")
        req.logger.debug("\(req.content)")

        let entryData = try req.content.decode(CreateEntryData.self)
        let entry = Entry(title: entryData.title, content: entryData.content)
        
        req.logger.debug("\(entry.description)")
        
        return entry.save(on: req.db).map { entry }
    }
    
    // Read
    @Sendable
    func get(req: Request) throws -> EventLoopFuture<Entry> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Entry.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    @Sendable
    func update(req: Request) throws -> EventLoopFuture<Entry> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let updatedEntry = try req.content.decode(Entry.self)
        return Entry.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { entry in
                entry.title = updatedEntry.title
                entry.content = updatedEntry.content
                return entry.save(on: req.db).map { entry }
            }
    }
    
    @Sendable
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Entry.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .noContent)
    }
}
