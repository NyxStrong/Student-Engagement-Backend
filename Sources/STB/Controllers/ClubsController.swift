import Fluent
import Vapor

struct ClubsControler: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let clubs = routes.grouped("clubs")
        clubs.get(use: getClubs)
        clubs.get(":id", use: getClub)
        // clubs.get(":id", "admin", use: getAdmins)
    }

    func getClubs(req: Request) async throws -> [ClubDTO] {
        var clubs: [ClubDTO] = []
        for club in try await Club.query(on: req.db).all() { 
            clubs.append(await ClubDTO(club: club, db: req.db) )
        }
        return clubs
    }
    
    func getClub(req: Request) async throws -> ClubDTO {
        let clubId: Int? = req.parameters.get("id", as: Int.self)
        do { 
            return try await ClubDTO(club: Club.find(clubId, on: req.db)!, db: req.db)
        } catch {
            throw Abort(.notFound)
        }
    }

    // func getAdmins(req: Request) async throws -> [UserDTO] {
    //     let clubId: Int? = req.parameters.get("id", as: Int.self)
    //     var admins: [UserDTO] = []
    //     for admin in try await Membership.query(on: req.db).filter(\.$club.$id == clubId!).filter(\.$admin == true).all() {
    //         try await admins.append(UserDTO(user: User.find(admin.user.id, on: req.db)!))
    //     }
    //     return admins
    // }

    func joinClub(req: Request) async throws -> HTTPStatus {
        let clubId: Int? = req.parameters.get("id", as: Int.self)
        let content = try req.content.decode(JoinClubReqDTO.self)
        do {
            let membership = Membership(userId: content.userId!, clubId: clubId!)
            try await membership.save(on: req.db)
            return .ok
        } catch {
            throw Abort(.badRequest)
        }
    }

    func approveJoinClub(req: Request) async throws -> HTTPStatus {
        let clubId: Int? = req.parameters.get("id", as: Int.self)
        let content = try req.content.decode(JoinClubApprovalReqDTO.self)
        do {
            if try await Membership.query(on: req.db)
                .filter(\.$user.$id == content.adminId!)
                .filter(\.$club.$id == clubId!)
                .first()!.admin
            {
                let membership = try await Membership.query(on: req.db)
                    .filter(\.$user.$id == content.userId!)
                    .filter(\.$club.$id == clubId!)
                    .first()!
                membership.status = 1
                try await membership.save(on: req.db)
                return .ok
            } else {
                throw Abort(.unauthorized)
            }
        } catch {
            throw Abort(.badRequest)
        }
    }
}