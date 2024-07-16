//
//  File.swift
//  
//
//  Created by Jungman Bae on 7/16/24.
//

import Vapor

// Entry 모델에 대한 CRUD 
struct JournalController {
    
    @Sendable
    func index(req: Request) throws -> EventLoopFuture<[Entry]> {
        return Entry.query(on: req.db).all()
    }
    
    func create(req: Request) throws -> EventLoopFuture<Entry> {
        let entry = try req.content.decode(Entry.self)
        return entry.save(on: req.db).map { entry }
    }
    
    func get(req: Request) throws -> EventLoopFuture<Entry> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Entry.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
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
