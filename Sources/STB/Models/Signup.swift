import Fluent

final class Signup: Model, @unchecked Sendable {
    static let schema = "signups"
    
    @ID(custom: "id")
    var id: Int?

    @Parent(key: "userId")
    var user: User

    @Parent(key: "eventId")
    var event: Event

    @Field(key: "rsvp")
    var rsvp: Bool

    @Field(key: "attendance")
    var attendance: Bool

    @Field(key: "participation")
    var participation: Int

    @Field(key: "rating")
    var rating: Int?

    @Field(key: "comments")
    var comment: String?

    init() { }

    init(userId: Int, eventId: Int, rsvp: Bool) {
        self.$user.id = userId
        self.$event.id = eventId
        self.rsvp = rsvp
        self.attendance = false
        self.participation = 0
    }

}
