import Fluent
import Vapor

struct UserEventDTO: Content {
    var id: Int?
    var name: String
    var type: UserType
    var studentId: Int?
    var points: Int
    var checkedin: Bool

    init(user: User, checkedin: Bool) async {
        self.id = user.id
        self.name = user.name
        self.type = user.type
        self.studentId = user.studentId
        self.points = user.points
        self.checkedin = checkedin
    }
}
