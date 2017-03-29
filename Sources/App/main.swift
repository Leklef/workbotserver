import Vapor
import VaporMySQL
import Fluent

let drop = Droplet()
try drop.addProvider(VaporMySQL.Provider.self)
drop.preparations.append(User.self)

//drop.get { request in
//    //return "Hello, Vapor!"
//    return try JSON(node: [
//            "message": "Hello,Vapor!"
//        ])
//}
//
//drop.get ("hello") { request in
//    //return "Hello, Vapor!"
//    return try JSON(node: [
//        "message": "Hello,again!"
//        ])
//}
//
//drop.get ("hello", "there") { request in
//    //return "Hello, Vapor!"
//    return try JSON(node: [
//        "message": "I'm tired of saying hello!"
//        ])
//}
//
//drop.get("beers", Int.self) { request, beers in
//    return try JSON(node: [
//        "message": "Take one down, pass it around, \(beers)"
//        ])
//}
//
//drop.post("post") { request in
//    guard let name = request.data["name"]?.string else {throw Abort.badRequest}
//    return try JSON(node:[
//            "name": "Hello, \(name)"
//        ])
//}

drop.get("version") { request in
    if let db = drop.database?.driver as? MySQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node:version)
    } else {
        return "No DB connection"
    }
}

drop.post("newuser") { request in
    var user = User(login: "admin", password: "admin", status: "admin")
    try user.save()
    return try JSON(node:[
            "id":user.id,
            "login":user.login,
            "password":user.password,
            "status":user.status
        ])
}

drop.post("getuser") { request in
    guard let id = request.data["id"]?.int else {throw Abort.badRequest}
    let user = try User.find(id)
    return try JSON(node:[
        "id":user!.id,
        "login":user!.login,
        "password":user!.password,
        "status":user!.status
        ])
}

drop.post("find") { request in
    guard let login = request.data["login"]?.string else {throw Abort.badRequest}
    guard let password = request.data["password"]?.string else {throw Abort.badRequest}
    let query = try User.query().filter("Login", login).filter("Password", password)
    guard let user = try query.makeQuery().first() else {throw Abort.badRequest}
    
    return try JSON(node:[
        "id":user.id,
        "status":user.status
    ])
}


drop.run()
