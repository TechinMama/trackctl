import Foundation

// MARK: - Local mock data service. No network calls — local-first per MVP spec.
@MainActor
class APIService {
    static let shared = APIService()

    // MARK: - Athletes

    func fetchAthletes() async throws -> [Athlete] {
        return MockData.athletes
    }

    func fetchAthlete(id: String) async throws -> Athlete {
        guard let athlete = MockData.athletes.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return athlete
    }

    func followAthlete(id: String) async throws {
        // Follow state is managed locally in AthleteViewModel + UserDefaults.
    }

    // MARK: - Meets

    func fetchMeets() async throws -> [Meet] {
        return MockData.meets
    }

    func fetchMeet(id: String) async throws -> Meet {
        guard let meet = MockData.meets.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return meet
    }

    func fetchUpcomingMeets() async throws -> [Meet] {
        return MockData.meets.filter { $0.status == .upcoming }
    }

    // MARK: - Results

    func fetchResults(eventID: String) async throws -> [Result] {
        return MockData.results.filter { $0.eventID == eventID }
    }

    // MARK: - Storylines

    func fetchCompetitiveStorylines() async throws -> [CompetitiveStoryline] {
        return MockData.storylines
    }
}

enum APIError: Error {
    case notFound
}

// MARK: - Mock Data

private enum MockData {

    // MARK: Shared date helpers
    static func date(_ iso: String) -> Date {
        let f = ISO8601DateFormatter()
        return f.date(from: iso) ?? Date()
    }

    // MARK: Results
    static let results: [Result] = [
        Result(
            id: "r1",
            athleteID: "a1",
            athleteName: "Sydney McLaughlin-Levrone",
            eventID: "e1",
            eventName: "400m Hurdles",
            placement: 1,
            time: "50.65",
            date: date("2026-03-21T18:30:00Z"),
            aiInsight: "McLaughlin-Levrone's 50.65 at World Indoors signals she's tracking toward another world record attempt outdoors. Her season opener pace is faster than her 2023 campaign at the same point—a historically significant benchmark with Paris momentum still building."
        ),
        Result(
            id: "r2",
            athleteID: "a2",
            athleteName: "Noah Lyles",
            eventID: "e2",
            eventName: "100m",
            placement: 1,
            time: "9.81",
            date: date("2026-03-22T19:15:00Z"),
            aiInsight: "Lyles' 9.81 in March represents elite early-season form. Historically, sub-9.85 performances before May correlate with peak-season sub-9.80 targets. He has won the last two World Championships 100m finals, and this trajectory supports continued dominance through the Diamond League."
        ),
        Result(
            id: "r3",
            athleteID: "a3",
            athleteName: "Faith Kipyegon",
            eventID: "e3",
            eventName: "1500m",
            placement: 1,
            time: "3:51.02",
            date: date("2026-04-05T17:00:00Z"),
            aiInsight: "Kipyegon's 3:51 in April is consistent with her championship-cycle pattern. She has won three consecutive World Championship 1500m titles and two Olympic golds. Her late-season surges consistently outpace her early marks—watch her Diamond League performances for world record targeting."
        ),
        Result(
            id: "r4",
            athleteID: "a4",
            athleteName: "Armand Duplantis",
            eventID: "e4",
            eventName: "Pole Vault",
            placement: 1,
            time: nil,
            date: date("2026-04-12T20:00:00Z"),
            aiInsight: "Duplantis cleared 6.25m to open the outdoor season, one centimeter below his current world record of 6.26m. He has broken the world record nine times since 2020. Early-season clearances near personal best levels are characteristic of his approach before targeting record attempts at Diamond League finals."
        ),
        Result(
            id: "r5",
            athleteID: "a5",
            athleteName: "Sha'Carri Richardson",
            eventID: "e5",
            eventName: "100m",
            placement: 1,
            time: "10.71",
            date: date("2026-04-18T18:45:00Z"),
            aiInsight: "Richardson's 10.71 season opener matches her 2025 championship pace. As reigning World Champion in the 100m, she enters the Diamond League as the defending circuit leader in this event. Her acceleration mechanics have been refined since Paris, and she's showing no sign of the inconsistency that characterized earlier seasons."
        )
    ]

    // MARK: Athletes
    static let athletes: [Athlete] = [
        Athlete(
            id: "a1",
            name: "Sydney McLaughlin-Levrone",
            country: "USA",
            discipline: "400m Hurdles",
            personalBest: "50.68 WR",
            profileImageURL: URL(string: "https://ui-avatars.com/api/?name=Sydney+McLaughlin-Levrone&background=1A2026&color=F2EDE0&size=256"),
            isFollowing: false,
            recentResults: [results[0]]
        ),
        Athlete(
            id: "a2",
            name: "Noah Lyles",
            country: "USA",
            discipline: "100m / 200m",
            personalBest: "9.83 / 19.70",
            profileImageURL: URL(string: "https://ui-avatars.com/api/?name=Noah+Lyles&background=1A2026&color=F2EDE0&size=256"),
            isFollowing: false,
            recentResults: [results[1]]
        ),
        Athlete(
            id: "a3",
            name: "Faith Kipyegon",
            country: "KEN",
            discipline: "1500m",
            personalBest: "3:49.11 WR",
            profileImageURL: URL(string: "https://ui-avatars.com/api/?name=Faith+Kipyegon&background=1A2026&color=F2EDE0&size=256"),
            isFollowing: false,
            recentResults: [results[2]]
        ),
        Athlete(
            id: "a4",
            name: "Armand Duplantis",
            country: "SWE",
            discipline: "Pole Vault",
            personalBest: "6.26m WR",
            profileImageURL: URL(string: "https://ui-avatars.com/api/?name=Armand+Duplantis&background=1A2026&color=F2EDE0&size=256"),
            isFollowing: false,
            recentResults: [results[3]]
        ),
        Athlete(
            id: "a5",
            name: "Sha'Carri Richardson",
            country: "USA",
            discipline: "100m / 200m",
            personalBest: "10.71 / 21.60",
            profileImageURL: URL(string: "https://ui-avatars.com/api/?name=Sha%27Carri+Richardson&background=1A2026&color=F2EDE0&size=256"),
            isFollowing: false,
            recentResults: [results[4]]
        ),
        Athlete(
            id: "a6",
            name: "Marcell Jacobs",
            country: "ITA",
            discipline: "100m",
            personalBest: "9.80",
            profileImageURL: URL(string: "https://ui-avatars.com/api/?name=Marcell+Jacobs&background=1A2026&color=F2EDE0&size=256"),
            isFollowing: false,
            recentResults: []
        ),
        Athlete(
            id: "a7",
            name: "Athing Mu",
            country: "USA",
            discipline: "800m",
            personalBest: "1:55.04",
            profileImageURL: URL(string: "https://ui-avatars.com/api/?name=Athing+Mu&background=1A2026&color=F2EDE0&size=256"),
            isFollowing: false,
            recentResults: []
        ),
        Athlete(
            id: "a8",
            name: "Jakob Ingebrigtsen",
            country: "NOR",
            discipline: "1500m / 5000m",
            personalBest: "3:43.73 / 12:48.45",
            profileImageURL: URL(string: "https://ui-avatars.com/api/?name=Jakob+Ingebrigtsen&background=1A2026&color=F2EDE0&size=256"),
            isFollowing: false,
            recentResults: []
        )
    ]

    // MARK: Events
    static let events: [Event] = [
        Event(id: "e1", name: "400m Hurdles Women", discipline: "400mH", meetID: "m1",
              scheduledTime: date("2026-05-09T19:30:00Z"), results: [results[0]]),
        Event(id: "e2", name: "100m Men", discipline: "100m", meetID: "m1",
              scheduledTime: date("2026-05-09T20:00:00Z"), results: [results[1]]),
        Event(id: "e3", name: "1500m Women", discipline: "1500m", meetID: "m2",
              scheduledTime: date("2026-05-30T19:15:00Z"), results: [results[2]]),
        Event(id: "e4", name: "Pole Vault Men", discipline: "Pole Vault", meetID: "m2",
              scheduledTime: date("2026-05-30T17:30:00Z"), results: [results[3]]),
        Event(id: "e5", name: "100m Women", discipline: "100m", meetID: "m3",
              scheduledTime: date("2026-06-11T20:30:00Z"), results: [results[4]]),
        Event(id: "e6", name: "800m Women", discipline: "800m", meetID: "m3",
              scheduledTime: date("2026-06-11T19:45:00Z"), results: []),
        Event(id: "e7", name: "100m Men Final", discipline: "100m", meetID: "m4",
              scheduledTime: date("2026-08-20T21:00:00Z"), results: []),
        Event(id: "e8", name: "400m Hurdles Women Final", discipline: "400mH", meetID: "m4",
              scheduledTime: date("2026-08-21T20:30:00Z"), results: [])
    ]

    // MARK: Meets
    static let meets: [Meet] = [
        Meet(
            id: "m1",
            name: "Doha Diamond League",
            location: "Doha, Qatar",
            date: date("2026-05-09T18:00:00Z"),
            events: [events[0], events[1]],
            competitiveLevel: "Diamond League",
            watchURL: URL(string: "https://worldathletics.org/diamond-league/doha"),
            status: .upcoming
        ),
        Meet(
            id: "m2",
            name: "Prefontaine Classic",
            location: "Eugene, Oregon, USA",
            date: date("2026-05-30T16:00:00Z"),
            events: [events[2], events[3]],
            competitiveLevel: "Diamond League",
            watchURL: URL(string: "https://prefontaineclassic.com"),
            status: .upcoming
        ),
        Meet(
            id: "m3",
            name: "Bislett Games",
            location: "Oslo, Norway",
            date: date("2026-06-11T18:00:00Z"),
            events: [events[4], events[5]],
            competitiveLevel: "Diamond League",
            watchURL: URL(string: "https://worldathletics.org/diamond-league/oslo"),
            status: .upcoming
        ),
        Meet(
            id: "m4",
            name: "World Athletics Championships",
            location: "Tokyo, Japan",
            date: date("2026-08-15T09:00:00Z"),
            events: [events[6], events[7]],
            competitiveLevel: "World Championships",
            watchURL: URL(string: "https://worldathletics.org/competitions/world-athletics-championships"),
            status: .upcoming
        ),
        Meet(
            id: "m5",
            name: "World Athletics Indoor Championships",
            location: "Nanjing, China",
            date: date("2026-03-21T09:00:00Z"),
            events: [],
            competitiveLevel: "World Championships",
            watchURL: URL(string: "https://worldathletics.org/competitions/world-athletics-indoor-championships"),
            status: .completed
        )
    ]

    // MARK: Storylines
    static let storylines: [CompetitiveStoryline] = [
        CompetitiveStoryline(
            id: "s1",
            title: "McLaughlin-Levrone's WR Trajectory",
            description: "Can she break 50.00?",
            relatedAthletes: [athletes[0]],
            relatedMeets: [meets[0], meets[3]],
            aiGeneratedInsight: "Sydney McLaughlin-Levrone has lowered the 400m hurdles world record four times since 2021, each time at a major championship. Her 50.68 WR from Paris stands as the benchmark. With Doha and Pre opening the 2026 outdoor season, the field is watching whether she targets the record before the World Championships in Tokyo.",
            createdDate: date("2026-04-28T12:00:00Z")
        ),
        CompetitiveStoryline(
            id: "s2",
            title: "Lyles vs. the Sprinting Hierarchy",
            description: "Can he reclaim undisputed 100m dominance?",
            relatedAthletes: [athletes[1], athletes[5]],
            relatedMeets: [meets[0], meets[3]],
            aiGeneratedInsight: "Noah Lyles enters 2026 as two-time defending World Champion in the 100m. His Paris Olympic gold was the most-discussed sprint of the decade. A healthy Lyles in the Diamond League circuit is meaningful—the depth of the global 100m field has increased, and any sub-9.80 this season will carry significant ranking weight.",
            createdDate: date("2026-04-28T12:00:00Z")
        ),
        CompetitiveStoryline(
            id: "s3",
            title: "Kipyegon and the Sub-3:49 Window",
            description: "Another world record attempt in 2026?",
            relatedAthletes: [athletes[2], athletes[7]],
            relatedMeets: [meets[1], meets[2]],
            aiGeneratedInsight: "Faith Kipyegon holds the 1500m world record at 3:49.11, set in Paris. She has indicated the Pre Classic and Oslo as priority meets. Her pattern of peaking in June-July makes the Bislett Games a credible record attempt window. Three world titles and two Olympic golds establish her as the standard-setter of her generation.",
            createdDate: date("2026-04-28T12:00:00Z")
        ),
        CompetitiveStoryline(
            id: "s4",
            title: "Duplantis: Every Meet is a Record Watch",
            description: "The 6.30m barrier is in range.",
            relatedAthletes: [athletes[3]],
            relatedMeets: [meets[1], meets[3]],
            aiGeneratedInsight: "Armand Duplantis has broken his own world record nine times. His current mark of 6.26m was set at Paris. He has publicly referenced 6.30m as a target. At every Diamond League meeting he competes in, conditions permitting, a record attempt is realistically on the table—making him among the most compelling single-event watches in sport.",
            createdDate: date("2026-04-29T09:00:00Z")
        )
    ]
}
