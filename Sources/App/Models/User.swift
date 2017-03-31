//
//  User.swift
//  WorkBotServer
//
//  Created by Ленар on 23.03.17.
//
//
import Vapor
import Fluent


final class User: Model {

    var id: Node?
    var login:String
    var password:String
    var status:String
    var exists: Bool = false
    
    enum Error: Swift.Error {
        case userNotFound
        case registerNotSupported
        case unsupportedCredentials
    }
    
    init(login:String, password:String, status:String) {
        self.login = login
        self.password = password
        self.status = status
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        login = try node.extract("Login")
        password = try node.extract("Password")
        status = try node.extract("Status")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "Login": login,
            "Password": password,
            "Status" : status
            ])
    }
    
    public static func prepare(_ database: Database) throws {
//        try database.create("users") { user in
//            user.id()
//            user.string("Login")
//            user.string("Password")
//            user.string("Status")
//        }
    }
    
    public static func revert(_ database: Database) throws {
        //try database.delete("users")
    }
}

import Auth

extension User: Auth.User {
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        let user: User?
        
        switch credentials {
        case let id as Identifier:
            user = try User.find(id.id)
        case let accessToken as AccessToken:
            user = try User.query().filter("access_token", accessToken.string).first()
        case let apiKey as APIKey:
            user = try User.query().filter("Login", apiKey.id).filter("Password", apiKey.secret).first()
        default:
            throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
        }
        
        guard let u = user else {
            throw Abort.custom(status: .badRequest, message: "User not found")
        }
        
        return u
    }
    
    
    static func register(credentials: Credentials) throws -> Auth.User {
        throw Abort.custom(status: .badRequest, message: "Register not supported.")
    }
}

import HTTP

extension Request {
    func user() throws -> User {
        guard let user = try auth.user() as? User else {
            throw Abort.custom(status: .badRequest, message: "Invalid user type.")
        }
        
        return user
    }
}


