import Fluent
import Vapor

struct UsersControler: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: getUsers)
        let user = users.grouped(":id")
        user.get(use: getUser)
    }

    func getUsers(req: Request) async throws -> [UserDTO] {
        try await User.query(on: req.db).all().map { UserDTO(user: $0) }
    }

    func getUser(req: Request) async throws -> UserDTO {
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let userdto = UserDTO(user: user)
        return userdto
    }
}
