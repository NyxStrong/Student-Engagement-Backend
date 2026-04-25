import Fluent
import Vapor

struct FeedbackControler: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("feedback", ":id", use: getFeedback)
        routes.post("feedback", "create", use: create)
    }

    func create(req: Request) async throws -> HTTPStatus {
        do {
            let content = try req.content.decode(CreateFeedbackReqDTO.self)
            guard let signup = try await Signup.query(on: req.db)
                .filter(\.$user.$id == content.userId)
                .filter(\.$event.$id == content.eventId)
                .first() else {
                    throw Abort(.badRequest)
                }
            signup.rating = content.rating
            signup.comment = content.comment
            try await signup.save(on: req.db)
            return .ok
        } catch {
            throw Abort(.badRequest)
        }

    }

    func getFeedback(req: Request) async throws -> [FeedbackDTO] {
        let eventId: Int? = req.parameters.get("id", as: Int.self)
        var feedbacks: [FeedbackDTO] = []

        do {
            feedbacks = try await Signup.query(on: req.db)
                .filter(\.$event.$id == eventId!)
                .filter(\.$rating != nil)
                .all().map { FeedbackDTO(signup: $0) }
        } catch {

        }
        return feedbacks
    }
}
