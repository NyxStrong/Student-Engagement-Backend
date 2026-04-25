import Fluent
import Foundation

let EventDateStyle = Date.FormatStyle()
    .year(.twoDigits)
    .month(.twoDigits)
    .day(.twoDigits)
    .hour(.twoDigits(amPM: .abbreviated))
    .minute(.twoDigits)

enum EventStatus: Int, Codable {
    case draft = 0
    case pending = 1
    case approved = 2
    case published = 3
    case completed = 4

    var text: String {
        switch self {
            case .draft: return "Draft"
            case .pending: return "Pending"
            case .approved: return "Approved"
            case .published: return "Published"
            case .completed: return "Completed"
        }
    }
}

final class Event: Model, @unchecked Sendable {
    static let schema = "events"
    
    @ID(custom: "id")
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Field(key: "location")
    var location: String

    @Field(key: "dateTime")
    var dateTime: Date

    @Field(key: "tag")
    var tag: String

    @Parent(key: "clubId")
    var club: Club

    @Field(key: "facilities")
    var facilities: Int

    @Field(key: "it")
    var it: Int

    @Field(key: "finance")
    var finance: Int

    @Field(key: "status")
    var status: Int

    init() { }

    init(name: String, description: String, location: String, dateTime: Date, tag: String, clubId: Int, facilities: Int, it: Int, finance: Int) {
        self.name = name
        self.description = description
        self.location = location
        self.dateTime = dateTime
        self.tag = tag
        self.$club.id = clubId
        self.facilities = facilities
        self.it = it
        self.finance = finance
        self.status = 0
    }

}
