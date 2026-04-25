import Fluent
import Foundation

struct SeedData: AsyncMigration {
    func prepare(on database: any Database) async throws {

        // MARK: - Users (1 admin + 20 students)

        let admin = User(name: "Dr. Sarah Mitchell", type: .admin)

        let students: [User] = [
            User(name: "Liam Okafor",        type: .student, studentId: 2300001),
            User(name: "Priya Nair",          type: .student, studentId: 2300002),
            User(name: "Marcus Webb",         type: .student, studentId: 2300003),
            User(name: "Sofia Delgado",       type: .student, studentId: 2300004),
            User(name: "James Thornton",      type: .student, studentId: 2300005),
            User(name: "Aisha Kamara",        type: .student, studentId: 2300006),
            User(name: "Ethan Liu",           type: .student, studentId: 2300007),
            User(name: "Chloe Beaumont",      type: .student, studentId: 2300008),
            User(name: "Noah Patel",          type: .student, studentId: 2300009),
            User(name: "Isabelle Morin",      type: .student, studentId: 2300010),
            User(name: "Dylan Ferreira",      type: .student, studentId: 2300011),
            User(name: "Zara Hassan",         type: .student, studentId: 2300012),
            User(name: "Owen Gallagher",      type: .student, studentId: 2300013),
            User(name: "Maya Krishnamurthy",  type: .student, studentId: 2300014),
            User(name: "Theo Nakamura",       type: .student, studentId: 2300015),
            User(name: "Fatima Al-Rashid",    type: .student, studentId: 2300016),
            User(name: "Caleb Johansson",     type: .student, studentId: 2300017),
            User(name: "Nia Osei",            type: .student, studentId: 2300018),
            User(name: "Remy Fontaine",       type: .student, studentId: 2300019),
            User(name: "Yuki Tanaka",         type: .student, studentId: 2300020),
        ]

        try await admin.save(on: database)
        for student in students { try await student.save(on: database) }

        // Assigned IDs after save: admin=1, students=2..21

        // MARK: - Clubs

        let techClub    = Club(name: "Tech Innovators Society")
        let ecoClub     = Club(name: "Green Campus Alliance")
        let debateClub  = Club(name: "Debate & Public Speaking Union")
        let artClub     = Club(name: "Creative Arts Collective")

        try await techClub.save(on: database)    // id: 1
        try await ecoClub.save(on: database)     // id: 2
        try await debateClub.save(on: database)  // id: 3
        try await artClub.save(on: database)     // id: 4

        // MARK: - Memberships

        // Tech Club: students 2,3,4,7,9,15,17
        let techMembers: [(userId: Int, admin: Bool)] = [
            (2, true), (3, false), (4, false), (7, false), (9, false), (15, false), (17, false)
        ]
        // Eco Club: students 5,6,8,12,14,18,20
        let ecoMembers: [(userId: Int, admin: Bool)] = [
            (5, true), (6, false), (8, false), (12, false), (14, false), (18, false), (20, false)
        ]
        // Debate Club: students 10,11,13,16,19
        let debateMembers: [(userId: Int, admin: Bool)] = [
            (10, true), (11, false), (13, false), (16, false), (19, false)
        ]
        // Art Club: students 4,8,14,15,20 (cross-club overlap intentional)
        let artMembers: [(userId: Int, admin: Bool)] = [
            (4, true), (8, false), (14, false), (15, false), (20, false)
        ]

        for m in techMembers   { try await Membership(userId: m.userId, clubId: 1, admin: m.admin).save(on: database) }
        for m in ecoMembers    { try await Membership(userId: m.userId, clubId: 2, admin: m.admin).save(on: database) }
        for m in debateMembers { try await Membership(userId: m.userId, clubId: 3, admin: m.admin).save(on: database) }
        for m in artMembers    { try await Membership(userId: m.userId, clubId: 4, admin: m.admin).save(on: database) }

        // MARK: - Date helpers

        let cal = Calendar.current
        func daysAgo(_ n: Int) -> Date {
            cal.date(byAdding: .day, value: -n, to: Date())!
        }
        func daysFromNow(_ n: Int) -> Date {
            cal.date(byAdding: .day, value: n, to: Date())!
        }

        // MARK: - Events (7 total: 5 past/completed, 2 upcoming)

        // Tech Club events
        let hackathon = Event(
            name: "Spring Hackathon 2025",
            description: "24-hour coding challenge open to all skill levels. Build something that matters.",
            location: "Engineering Block B, Room 204",
            dateTime: daysAgo(30),
            tag: "Creative",
            clubId: 1,
            facilities: 2, it: 2, finance: 1
        )
        let aiWorkshop = Event(
            name: "Intro to Machine Learning Workshop",
            description: "Hands-on session covering supervised learning fundamentals using Python and scikit-learn.",
            location: "Computer Lab 3",
            dateTime: daysAgo(14),
            tag: "Popular",
            clubId: 1,
            facilities: 1, it: 2, finance: 0
        )
        let techTalk = Event(
            name: "Industry Tech Talk: AI in Healthcare",
            description: "Guest speaker from MedTech startup discussing real-world AI applications.",
            location: "Auditorium A",
            dateTime: daysFromNow(10),
            tag: "Impact",
            clubId: 1,
            facilities: 2, it: 1, finance: 0
        )

        // Eco Club events
        let campusCleanup = Event(
            name: "Campus Clean-Up Day",
            description: "Community clean-up drive across the main campus grounds. Gloves provided.",
            location: "Main Campus Grounds",
            dateTime: daysAgo(21),
            tag: "Impact",
            clubId: 2,
            facilities: 1, it: 0, finance: 0
        )
        let sustainabilityPanel = Event(
            name: "Sustainability & Zero Waste Panel",
            description: "Panel discussion with faculty researchers on campus sustainability initiatives.",
            location: "Lecture Hall C",
            dateTime: daysAgo(7),
            tag: "Social",
            clubId: 2,
            facilities: 1, it: 1, finance: 0
        )

        // Debate Club events
        let debateTournament = Event(
            name: "Semester Debate Tournament",
            description: "Competitive debate tournament. Motion: 'This house would ban social media for under-18s.'",
            location: "Conference Room 1",
            dateTime: daysAgo(10),
            tag: "Fun",
            clubId: 3,
            facilities: 1, it: 0, finance: 1
        )

        // Art Club events
        let galleryNight = Event(
            name: "End-of-Term Gallery Night",
            description: "Student art showcase featuring paintings, digital art, and sculpture. Open to all.",
            location: "Student Union Gallery",
            dateTime: daysFromNow(18),
            tag: "Social",
            clubId: 4,
            facilities: 2, it: 0, finance: 2
        )

        try await hackathon.save(on: database)          // id: 1
        try await aiWorkshop.save(on: database)         // id: 2
        try await techTalk.save(on: database)           // id: 3
        try await campusCleanup.save(on: database)      // id: 4
        try await sustainabilityPanel.save(on: database)// id: 5
        try await debateTournament.save(on: database)   // id: 6
        try await galleryNight.save(on: database)       // id: 7

        // Mark past events as completed
        hackathon.status = EventStatus.completed.rawValue
        aiWorkshop.status = EventStatus.completed.rawValue
        campusCleanup.status = EventStatus.completed.rawValue
        sustainabilityPanel.status = EventStatus.completed.rawValue
        debateTournament.status = EventStatus.completed.rawValue
        try await hackathon.update(on: database)
        try await aiWorkshop.update(on: database)
        try await campusCleanup.update(on: database)
        try await sustainabilityPanel.update(on: database)
        try await debateTournament.update(on: database)

        // Upcoming events: pending approval
        techTalk.status = EventStatus.pending.rawValue
        galleryNight.status = EventStatus.draft.rawValue
        try await techTalk.update(on: database)
        try await galleryNight.update(on: database)

        // MARK: - Signups & Attendance History

        // Helper to build and save a signup
        func signup(userId: Int, eventId: Int, rsvp: Bool, attended: Bool, participation: Int, rating: Int? = nil, comment: String? = nil) async throws {
            let s = Signup(userId: userId, eventId: eventId, rsvp: rsvp)
            s.attendance = attended
            s.participation = participation
            s.rating = rating
            s.comment = comment
            try await s.save(on: database)
        }

        // --- Event 1: Spring Hackathon (past, high attendance) ---
        // Attendees from tech club + a few cross-club students
        try await signup(userId: 2,  eventId: 1, rsvp: true,  attended: true,  participation: 9, rating: 9, comment: "Best event of the semester!")
        try await signup(userId: 3,  eventId: 1, rsvp: true,  attended: true,  participation: 8, rating: 8)
        try await signup(userId: 4,  eventId: 1, rsvp: true,  attended: true,  participation: 7, rating: 7)
        try await signup(userId: 7,  eventId: 1, rsvp: true,  attended: true,  participation: 10, rating: 9, comment: "Incredible challenge, loved it.")
        try await signup(userId: 9,  eventId: 1, rsvp: true,  attended: false, participation: 0)  // no-show
        try await signup(userId: 15, eventId: 1, rsvp: true,  attended: true,  participation: 6, rating: 7)
        try await signup(userId: 17, eventId: 1, rsvp: true,  attended: true,  participation: 8, rating: 8)
        try await signup(userId: 11, eventId: 1, rsvp: true,  attended: true,  participation: 5, rating: 6)  // cross-club
        try await signup(userId: 19, eventId: 1, rsvp: true,  attended: true,  participation: 7, rating: 7)  // cross-club
        try await signup(userId: 20, eventId: 1, rsvp: false, attended: false, participation: 0)             // signed up but didn't rsvp

        // --- Event 2: ML Workshop (past, moderate attendance) ---
        try await signup(userId: 2,  eventId: 2, rsvp: true,  attended: true,  participation: 8, rating: 8)
        try await signup(userId: 3,  eventId: 2, rsvp: true,  attended: true,  participation: 7, rating: 9, comment: "Very clear explanations.")
        try await signup(userId: 7,  eventId: 2, rsvp: true,  attended: false, participation: 0)  // no-show
        try await signup(userId: 9,  eventId: 2, rsvp: true,  attended: true,  participation: 6, rating: 7)
        try await signup(userId: 15, eventId: 2, rsvp: true,  attended: true,  participation: 9, rating: 9, comment: "Finally understood backprop!")
        try await signup(userId: 17, eventId: 2, rsvp: false, attended: false, participation: 0)
        try await signup(userId: 14, eventId: 2, rsvp: true,  attended: true,  participation: 5, rating: 6)  // cross-club

        // --- Event 3: Industry Tech Talk (upcoming — RSVPs only) ---
        try await signup(userId: 2,  eventId: 3, rsvp: true,  attended: false, participation: 0)
        try await signup(userId: 3,  eventId: 3, rsvp: true,  attended: false, participation: 0)
        try await signup(userId: 9,  eventId: 3, rsvp: true,  attended: false, participation: 0)
        try await signup(userId: 15, eventId: 3, rsvp: true,  attended: false, participation: 0)
        try await signup(userId: 17, eventId: 3, rsvp: false, attended: false, participation: 0)

        // --- Event 4: Campus Clean-Up (past, very high attendance) ---
        try await signup(userId: 5,  eventId: 4, rsvp: true,  attended: true,  participation: 9, rating: 8)
        try await signup(userId: 6,  eventId: 4, rsvp: true,  attended: true,  participation: 8, rating: 8, comment: "Great to give back to campus.")
        try await signup(userId: 8,  eventId: 4, rsvp: true,  attended: true,  participation: 7, rating: 7)
        try await signup(userId: 12, eventId: 4, rsvp: true,  attended: true,  participation: 10, rating: 9)
        try await signup(userId: 14, eventId: 4, rsvp: true,  attended: false, participation: 0)  // no-show
        try await signup(userId: 18, eventId: 4, rsvp: true,  attended: true,  participation: 8, rating: 8)
        try await signup(userId: 20, eventId: 4, rsvp: true,  attended: true,  participation: 6, rating: 7)
        try await signup(userId: 4,  eventId: 4, rsvp: true,  attended: true,  participation: 5, rating: 6)   // cross-club
        try await signup(userId: 16, eventId: 4, rsvp: true,  attended: true,  participation: 7, rating: 8)  // cross-club

        // --- Event 5: Sustainability Panel (past, moderate attendance) ---
        try await signup(userId: 5,  eventId: 5, rsvp: true,  attended: true,  participation: 8, rating: 7)
        try await signup(userId: 6,  eventId: 5, rsvp: true,  attended: false, participation: 0)  // no-show
        try await signup(userId: 8,  eventId: 5, rsvp: true,  attended: true,  participation: 6, rating: 8, comment: "The panel was eye-opening.")
        try await signup(userId: 12, eventId: 5, rsvp: true,  attended: true,  participation: 7, rating: 7)
        try await signup(userId: 18, eventId: 5, rsvp: true,  attended: true,  participation: 5, rating: 6)
        try await signup(userId: 20, eventId: 5, rsvp: false, attended: false, participation: 0)

        // --- Event 6: Debate Tournament (past) ---
        try await signup(userId: 10, eventId: 6, rsvp: true,  attended: true,  participation: 10, rating: 9, comment: "Fantastic experience moderating.")
        try await signup(userId: 11, eventId: 6, rsvp: true,  attended: true,  participation: 9, rating: 9)
        try await signup(userId: 13, eventId: 6, rsvp: true,  attended: true,  participation: 8, rating: 8)
        try await signup(userId: 16, eventId: 6, rsvp: true,  attended: false, participation: 0)  // no-show
        try await signup(userId: 19, eventId: 6, rsvp: true,  attended: true,  participation: 7, rating: 7)
        try await signup(userId: 3,  eventId: 6, rsvp: true,  attended: true,  participation: 6, rating: 8)  // cross-club

        // --- Event 7: Gallery Night (upcoming — RSVPs only) ---
        try await signup(userId: 4,  eventId: 7, rsvp: true,  attended: false, participation: 0)
        try await signup(userId: 8,  eventId: 7, rsvp: true,  attended: false, participation: 0)
        try await signup(userId: 14, eventId: 7, rsvp: true,  attended: false, participation: 0)
        try await signup(userId: 15, eventId: 7, rsvp: true,  attended: false, participation: 0)
        try await signup(userId: 20, eventId: 7, rsvp: false, attended: false, participation: 0)
    }

    func revert(on database: any Database) async throws {
        try await Membership.query(on: database).delete()
        try await Signup.query(on: database).delete()
        try await Event.query(on: database).delete()
        try await Club.query(on: database).delete()
        try await User.query(on: database).delete()
    }
}