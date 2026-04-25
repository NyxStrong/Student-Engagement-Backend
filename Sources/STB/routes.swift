import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: UsersControler())
    try app.register(collection: EventsController())
    try app.register(collection: ClubsControler())
    try app.register(collection: FeedbackControler())
}
