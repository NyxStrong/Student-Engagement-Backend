import Fluent

enum UserType: String, Codable {
    case student, admin
}

final class User: Model, @unchecked Sendable {
    static let schema = "users"
    
    @ID(custom: "id")
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "type")
    var type: UserType

    @Field(key: "studentId")
    var studentId: Int?

    @Field(key: "points")
    var points: Int

    init() { }

    init(name: String, type: UserType, studentId: Int? = nil) {
        self.name = name
        self.type = type
        self.studentId = studentId
        self.points = 0
    }

}
