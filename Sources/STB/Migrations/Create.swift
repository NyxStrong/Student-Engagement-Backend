import Fluent

struct Create: AsyncMigration {
    func prepare(on database: any Database) async throws {
        // create users table
        _ = try? await database.enum("userType")
            .case("student")
            .case("admin")
            .create()
        
        let userType = try await database.enum("userType").read()
        try await database.schema("users")
            .field("id", .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("type", userType, .required)
            .field("studentId", .int)
            .field("points", .int, .required, .sql(.default(0)))
            .unique(on: "studentId")
            .create()
        
        // create clubs table
        try await database.schema("clubs")
            .field("id", .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("status", .int, .required, .sql(.default(0)))
            .constraint(.custom("CHECK (status BETWEEN 0 AND 2)"))
            .create()

        // create events table
        try await database.schema("events")
            .field("id", .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("location", .string, .required)
            .field("dateTime", .datetime, .required)
            .field("tag", .string, .required)
            .field("clubId", .int, .required, .references("clubs", "id"))
            .field("facilities", .int)
            .field("it", .int)
            .field("finance", .int)
            .field("status", .int, .required, .sql(.default(0)))
            .constraint(.custom("CHECK (facilities BETWEEN 0 AND 2)"))
            .constraint(.custom("CHECK (it BETWEEN 0 AND 2)"))
            .constraint(.custom("CHECK (finance BETWEEN 0 AND 2)"))
            .constraint(.custom("CHECK (status BETWEEN 0 AND 4)"))
            .create()
        
        // create feedback table
        // try await database.schema("feedback")
        //     .field("id", .int, .identifier(auto: true))
        //     .field("userId", .int, .required, .references("users", "id"))
        //     .field("eventId", .int, .required, .references("events", "id"))
        //     .field("rating", .int, .required)
        //     .field("comments", .int, .required)
        //     .constraint(.custom("CHECK (rating BETWEEN 0 AND 9)"))
        //     .create()
        
        // create signups table
        try await database.schema("signups")
            .field("id", .int, .identifier(auto: true))
            .field("userId", .int, .required, .references("users", "id"))
            .field("eventId", .int, .required, .references("events", "id"))
            .field("rsvp", .bool, .required, .sql(.default(false)))
            .field("attendance", .bool, .required, .sql(.default(false)))
            .field("participation", .int, .required, .sql(.default(0)))
            .field("rating", .int)
            .field("comments", .int)
            .constraint(.custom("CHECK (participation BETWEEN 0 AND 10)"))
            .constraint(.custom("CHECK (rating BETWEEN 0 AND 9)"))
            .create()
        
        // create memberships table
        try await database.schema("memberships")
            .field("id", .int, .identifier(auto: true))
            .field("userId", .int, .required, .references("users", "id"))
            .field("clubId", .int, .required, .references("clubs", "id"))
            .field("status", .int, .required, .sql(.default(0)))
            .field("admin", .bool, .required, .sql(.default(false)))
            .constraint(.custom("CHECK (status BETWEEN 0 AND 2)"))
            .create()


    }

    func revert(on database: any Database) async throws {
        try await database.schema("memberships").delete()
        try await database.schema("signups").delete()
        // try await database.schema("feedback").delete()
        try await database.schema("events").delete()
        try await database.schema("clubs").delete()
        try await database.schema("users").delete()
        try await database.enum("userType").delete()
    }
}
