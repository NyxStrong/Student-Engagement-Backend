import Fluent
import Vapor

struct CheckinReqDTO: Content {
    var userId: Int?
    var adminId: Int?
}
