import Fluent
import Vapor



struct CreateFeedbackReqDTO: Content {
    var userId: Int
    var eventId: Int
    var rating: Int
    var comment: String
}
