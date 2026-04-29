import XCTest
@testable import Athena

final class AthenaCoreLogicTests: XCTestCase {
    private let defaults = UserDefaults.standard

    override func tearDown() {
        defaults.removeObject(forKey: "athena.liveAPIEnabled")
        defaults.removeObject(forKey: "athena.intelligentInsightsEnabled")
        super.tearDown()
    }

    @MainActor
    func testMomentumScoreHigherForWinningRecentAthlete() {
        let viewModel = AthleteViewModel()
        let now = Date()

        let strong = Athlete(
            id: "a-strong",
            name: "Strong Athlete",
            country: "USA",
            discipline: "400m",
            personalBest: "44.00",
            profileImageURL: nil,
            isFollowing: false,
            recentResults: [
                Result(
                    id: "r-strong",
                    athleteID: "a-strong",
                    athleteName: "Strong Athlete",
                    eventID: "e-1",
                    eventName: "400m",
                    placement: 1,
                    time: "44.20",
                    date: now,
                    aiInsight: nil
                )
            ]
        )

        let developing = Athlete(
            id: "a-dev",
            name: "Developing Athlete",
            country: "USA",
            discipline: "400m",
            personalBest: "46.00",
            profileImageURL: nil,
            isFollowing: false,
            recentResults: [
                Result(
                    id: "r-dev",
                    athleteID: "a-dev",
                    athleteName: "Developing Athlete",
                    eventID: "e-1",
                    eventName: "400m",
                    placement: 7,
                    time: "46.40",
                    date: now.addingTimeInterval(-70 * 24 * 3600),
                    aiInsight: nil
                )
            ]
        )

        XCTAssertGreaterThan(viewModel.momentumScore(for: strong), viewModel.momentumScore(for: developing))
        XCTAssertEqual(viewModel.momentumLabel(for: strong), "In Form")
    }

    @MainActor
    func testWatchPriorityFavorsMajorSoonMeet() {
        let viewModel = MeetViewModel()
        let soonDate = Date().addingTimeInterval(2 * 24 * 3600)
        let laterDate = Date().addingTimeInterval(30 * 24 * 3600)

        let majorMeet = Meet(
            id: "m-major",
            name: "World Championships",
            location: "Tokyo",
            date: soonDate,
            events: [
                Event(id: "e-1", name: "100m", discipline: "100m", meetID: "m-major", scheduledTime: soonDate, results: [])
            ],
            competitiveLevel: "World Championships",
            watchURL: URL(string: "https://example.com/live"),
            status: .upcoming
        )

        let minorMeet = Meet(
            id: "m-minor",
            name: "Regional Open",
            location: "Somewhere",
            date: laterDate,
            events: [],
            competitiveLevel: "Regional",
            watchURL: nil,
            status: .upcoming
        )

        XCTAssertGreaterThan(viewModel.watchPriorityScore(for: majorMeet), viewModel.watchPriorityScore(for: minorMeet))
        XCTAssertEqual(viewModel.watchPriorityLabel(for: majorMeet), "Elite Watch")
    }

    func testInsightGuardrailDisablesGeneratedInsightAndResultText() async {
        defaults.set(false, forKey: "athena.intelligentInsightsEnabled")
        defaults.set(false, forKey: "athena.liveAPIEnabled")

        let storylineResponse = await APIService.shared.fetchCompetitiveStorylines()
        let resultResponse = await APIService.shared.fetchResults(eventID: "e1")

        XCTAssertFalse(storylineResponse.value.isEmpty)
        XCTAssertEqual(storylineResponse.value[0].aiGeneratedInsight, "Insight unavailable pending guardrail review.")

        XCTAssertFalse(resultResponse.value.isEmpty)
        XCTAssertNil(resultResponse.value[0].aiInsight)
    }
}
