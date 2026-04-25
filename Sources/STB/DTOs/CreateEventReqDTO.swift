import Fluent
import Vapor



struct CreateEventReqDTO: Content {
    var adminId: Int
    var name: String
    var description: String
    var location: String
    var dateTime: String
    var tag: String
    var clubId: Int
    var requirements: [String: Bool]
}
