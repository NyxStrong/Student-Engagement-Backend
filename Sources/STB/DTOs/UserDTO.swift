import Fluent
import Vapor

struct UserDTO: Content {
    var id: Int?
    var name: String
    var type: UserType
    var studentId: Int?
    var points: Int

    init(user: User) {
        self.id = user.id
        self.name = user.name
        self.type = user.type
        self.studentId = user.studentId
        self.points = user.points
    }
}
