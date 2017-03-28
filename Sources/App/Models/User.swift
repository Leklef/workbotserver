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
        try database.create("users") { user in
            user.id()
            user.string("Login")
            user.string("Password")
            user.string("Status")
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("users")
    }
}


