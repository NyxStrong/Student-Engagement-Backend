import Fluent
import Vapor

struct EventsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let events = routes.grouped("events")
        events.get(use: getEvents)
        events.post("create", use: create)
        let event = events.grouped(":id")
        event.get(use: getEvent)
        event.post("rsvp", use: rsvp)
        event.post("checkin", use: checkin)
        event.post("submit", use: eventManage)
        event.post("approve", use: eventManage)
        event.post("publish", use: eventManage)
        event.post("complete", use: eventManage)


    }

    func getEvents(req: Request) async throws -> [EventDTO] {
        var retEvents: [EventDTO] = []
        let events = try await Event.query(on: req.db).all()
        for event in events {
            retEvents.append(await EventDTO(event: event, db: req.db))
        }
        return retEvents
    }  

    func create(req: Request) async throws -> Int {
        do {
            let content = try req.content.decode(CreateEventReqDTO.self) 
            let event = Event(
                name: content.name, 
                description: content.description, 
                location: content.location, 
                dateTime: try EventDateStyle.parse(content.dateTime), 
                tag: content.tag,
                clubId: content.clubId, 
                facilities: content.requirements["facilities"]! ? 1 : 0, 
                it: content.requirements["it"]! ? 1 : 0, 
                finance: content.requirements["finance"]! ? 1 : 0)
            try await event.save(on: req.db)
            return event.id!
        } catch {
            throw Abort(.badRequest)
        }
    } 

    func getEvent(req: Request) async throws -> EventDTO {
        
        guard let event  = try await Event.find(req.parameters.get("id"), on: req.db) else { 
            throw Abort(.notFound) 
        }
        let eventdto = await EventDTO(event: event, db: req.db)
        return eventdto
    }

    func rsvp(req: Request) async throws -> HTTPStatus {
        let eventId = req.parameters.get("id", as: Int.self)
        let userId = try req.content.decode(RsvpReqDTO.self).userId
        
        do {
            let signup = try await Signup.query(on: req.db)
                .filter(\.$user.$id == userId!)
                .filter(\.$event.$id == eventId!)
                .first()!
            try await signup.delete(on: req.db)
        } catch {
            let signup = Signup(userId: userId!, eventId: eventId!, rsvp: true)
            try await signup.save(on: req.db)
        }

        return .ok
    }

    func checkin(req: Request) async throws -> HTTPStatus {
        let eventId = req.parameters.get("id", as: Int.self)
        let checkin = try req.content.decode(CheckinReqDTO.self)
        let userId = checkin.userId
        let adminId = checkin.adminId

        if
        let event = try await Event.find(eventId, on: req.db),
        let membership = try await Membership.query(on: req.db)
            .filter(\.$user.$id == adminId!)
            .filter(\.$club.$id == event.$club.id).first(),
        membership.admin,
        let signup = try await Signup.query(on: req.db)
            .filter(\.$user.$id == userId!)
            .filter(\.$event.$id == eventId!).first()
        {
            signup.attendance = true
            try await signup.save(on: req.db)
        } else {
            throw Abort(.notFound)
        }

        return .ok
    }

    func eventManage(req: Request) async throws -> HTTPStatus {
        let state = req.url.path.components(separatedBy: "/").last
        let adminId: Int = try req.content.decode(EventMagageReqDTO.self).adminId
        let eventId: Int? = req.parameters.get("id", as: Int.self)

        if 
        let admin = try await User.find(adminId, on: req.db),
        let event = try await Event.find(eventId, on: req.db)
        {
            switch state! {
                case "submit", "publish", "complete":
                    if
                    let membership = try await Membership.query(on: req.db)
                        .filter(\.$user.$id == admin.id!)
                        .filter(\.$club.$id == event.$club.id).first(),
                    (membership.admin) && (event.status < 5) && (event.status != 1) {
                        event.status += 1
                        try await event.save(on: req.db)
                        return .ok 
                    } else {
                        throw Abort(.badRequest)
                    }
                case "approve":
                    if (admin.type == UserType(rawValue: "admin")) {
                        event.status = 2
                        if event.facilities == 1 { event.facilities = 2 }
                        if event.it == 1 { event.it = 2 }
                        if event.finance == 1 { event.finance = 2 }
                        try await event.save(on: req.db)
                        return .ok
                    } else {
                        throw Abort(.badRequest)
                    }
                case _:
                    throw Abort(.notFound)
            }
        } else {
            throw Abort(.badRequest)
        }
    }
}
