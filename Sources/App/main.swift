import Vapor
import VaporMySQL
import Fluent
import Auth
import TLS

let drop = Droplet()

try drop.addProvider(VaporMySQL.Provider.self)
drop.preparations.append(User.self)
let auth = AuthMiddleware(user: User.self)
drop.middleware.append(auth)
drop.preparations = [User.self]


drop.get("version") { request in
    if let db = drop.database?.driver as? MySQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node:version)
    } else {
        return "No DB connection"
    }
}

drop.group("users") { users in
    users.post { req in
        guard let login = req.data["login"]?.string else {
            throw Abort.badRequest
        }
        guard let password = req.data["password"]?.string else {throw Abort.badRequest}
        guard let status = req.data["status"]?.string else {throw Abort.badRequest}
        
        var user = User(login: login, password: password, status: status)
        try user.save()
        return user
    }
    
    users.post("login") { req in
        guard let login = req.data["login"]?.string else {
            throw Abort.badRequest
        }
        guard let password = req.data["password"]?.string else {
            throw Abort.badRequest
        }
        let creds = APIKey.init(id: login, secret: password)
        try req.auth.login(creds)
        let query = try User.query().filter("id", try User.authenticate(credentials: creds).id!)
        guard let user = try query.makeQuery().first() else {throw Abort.badRequest}
        return try JSON(node: ["id": user.id, "status":user.status])
    }
    
    let protect = ProtectMiddleware(error:
        Abort.custom(status: .forbidden, message: "Not authorized.")
    )
    users.group(protect) { secure in
        secure.get("secure") { req in
            return try req.user()
        }
    }
}


drop.run()
