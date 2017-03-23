import Vapor
import VaporMySQL

let drop = Droplet()
try drop.addProvider(VaporMySQL.Provider.self)

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

drop.run()
