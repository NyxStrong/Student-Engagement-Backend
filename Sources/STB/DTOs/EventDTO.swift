import Fluent
import Vapor
import Foundation

struct EventDTO: Content {
    var id: Int?
    var name: String
    var description: String
    var location: String
    var dateTime: String
    var tag: String
    var clubId: Int
    var facilities: Int
    var it: Int
    var finance: Int
    var status: Int
    var users: [UserEventDTO]

    init(event: Event, db: any Database) async {
        self.id = event.id
        self.name = event.name
        self.description = event.description
        self.location = event.location
        self.dateTime = event.dateTime.formatted(EventDateStyle)
        self.tag = event.tag
        self.clubId = event.$club.id
        self.facilities = event.facilities
        self.it = event.it
        self.finance = event.finance
        self.status = event.status
        do {
            let userIds = try await Signup.query(on: db).filter(\.$event.$id == event.id!).all().map {
                $0.$user.id
            }
            self.users = []
            for userId in userIds {
                try await self.users.append(
                    UserEventDTO(
                        user: try await User.find(userId, on: db)!, 
                        checkedin: Signup.query(on: db)
                            .filter(\.$event.$id == event.id!)
                            .filter(\.$user.$id == userId)
                            .first()!.attendance == true
                    )
                )

            }
        } catch {
            self.users = []
        }

    }
}
