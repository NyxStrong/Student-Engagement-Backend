import Fluent

final class Club: Model, @unchecked Sendable {
    static let schema = "clubs"
    
    @ID(custom: "id")
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "status")
    var status: Int

    init() { }

    init(name: String) {
        self.name = name
        self.status = 0
    }

}
