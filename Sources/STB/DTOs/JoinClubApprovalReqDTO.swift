import Fluent
import Vapor

struct JoinClubApprovalReqDTO: Content {
    var userId: Int?
    var adminId: Int?
}
