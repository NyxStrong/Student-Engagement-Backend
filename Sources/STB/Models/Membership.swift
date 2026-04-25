import Fluent

final class Membership: Model, @unchecked Sendable {
    static let schema = "memberships"
    
    @ID(custom: "id")
    var id: Int?

    @Parent(key: "userId")
    var user: User

    @Parent(key: "clubId")
    var club: Club

    @Field(key: "admin")
    var admin: Bool

    @Field(key: "status")
    var status: Int

    init() { }

    init(userId: Int, clubId: Int, admin: Bool = false) {
        self.$user.id = userId
        self.$club.id = clubId
        self.admin = admin
        self.status = 0
    }

}
