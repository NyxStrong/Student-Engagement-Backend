import Fluent
import Vapor
import Foundation

struct ClubDTO: Content {
    var id: Int?
    var name: String
    var status: Int
    var users: [UserDTO]
    var events: [EventDTO]

    init(club: Club, db: any Database) async {
        self.id = club.id
        self.name = club.name
        self.status = club.status
        self.events = []
        do {
            for event in try await Event.query(on: db).filter(\.$club.$id == club.id!).all() {
                await self.events.append(EventDTO(event: event, db: db))
            }
        } catch {}
        
        self.users = []
        do {
            for membership in try await Membership.query(on: db).filter(\.$club.$id == club.id!).all() {
                self.users.append(UserDTO(user: try await User.find(membership.user.id, on: db)!))
            }
        } catch {}
    }
}
