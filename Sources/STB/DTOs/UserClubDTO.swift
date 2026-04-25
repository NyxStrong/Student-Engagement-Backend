import Fluent
import Vapor

struct UserClubDTO: Content {
    var id: Int?
    var name: String
    var type: UserType
    var studentId: Int?
    var points: Int
    var admin: Bool
    var joinStatus: Int

    init(user: User, membership: Membership) {
        self.id = user.id
        self.name = user.name
        self.type = user.type
        self.studentId = user.studentId
        self.points = user.points
        self.admin = membership.admin
        self.joinStatus = membership.status
    }
}
