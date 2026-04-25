import Fluent
import Vapor

struct FeedbackDTO: Content {
    var userId: Int
    var eventId: Int
    var rating: Int
    var comment: String?

    init(signup: Signup) {
        self.userId = signup.$user.id
        self.eventId = signup.$event.id
        self.rating = signup.rating!
        self.comment = signup.comment
    }
}
