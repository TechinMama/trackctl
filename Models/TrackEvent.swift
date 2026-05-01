import Foundation

// MARK: - Validated against World Athletics official disciplines (worldathletics.org/disciplines)
// and LA28 Olympic programme. Last verified: May 2026.
// Notable updates from older lists:
//   - Race walk is 35K (replaced 50K in 2022)
//   - Mixed 4x400m relay is an official Olympic/World Champs event since Tokyo 2020
//   - Mixed 4x100m relay featured at World Relays
//   - Indoor season adds 60m

enum TrackEventCategory: String, CaseIterable, Codable {
    case sprints        = "Sprints"
    case middleLong     = "Middle / Long"
    case hurdles        = "Hurdles"
    case relays         = "Relays"
    case jumps          = "Jumps"
    case throws         = "Throws"
    case combinedEvents = "Combined Events"
    case raceWalk       = "Race Walk"
    case roadRunning    = "Road Running"
    case crossCountry   = "Cross Country"
    case indoorOnly     = "Indoor"
}

enum TrackEvent: String, CaseIterable, Codable, Identifiable {
    // MARK: Sprints
    case m100       = "100m"
    case m200       = "200m"
    case m400       = "400m"

    // MARK: Middle / Long
    case m800       = "800m"
    case m1500      = "1500m"
    case mile       = "Mile"
    case m3000      = "3000m"
    case m5000      = "5000m"
    case m10000     = "10000m"
    case sc3000     = "3000m Steeplechase"

    // MARK: Hurdles
    case h100       = "100m Hurdles"
    case h110       = "110m Hurdles"
    case h400       = "400m Hurdles"

    // MARK: Relays
    case relay4x100       = "4x100m Relay"
    case relay4x400       = "4x400m Relay"
    case relayMixed4x400  = "Mixed 4x400m Relay"
    case relayMixed4x100  = "Mixed 4x100m Relay"

    // MARK: Jumps
    case highJump     = "High Jump"
    case poleVault    = "Pole Vault"
    case longJump     = "Long Jump"
    case tripleJump   = "Triple Jump"

    // MARK: Throws
    case shotPut      = "Shot Put"
    case discus       = "Discus Throw"
    case hammer       = "Hammer Throw"
    case javelin      = "Javelin Throw"

    // MARK: Combined Events
    case heptathlon   = "Heptathlon"
    case decathlon    = "Decathlon"

    // MARK: Race Walk
    case raceWalk20k  = "20K Race Walk"
    case raceWalk35k  = "35K Race Walk"

    // MARK: Road Running
    case fiveK        = "5K"
    case tenK         = "10K"
    case halfMarathon = "Half Marathon"
    case marathon     = "Marathon"

    // MARK: Cross Country
    case crossCountry = "Cross Country"

    // MARK: Indoor only
    case m60          = "60m"

    var id: String { rawValue }

    var category: TrackEventCategory {
        switch self {
        case .m100, .m200, .m400:
            return .sprints
        case .m800, .m1500, .mile, .m3000, .m5000, .m10000, .sc3000:
            return .middleLong
        case .h100, .h110, .h400:
            return .hurdles
        case .relay4x100, .relay4x400, .relayMixed4x400, .relayMixed4x100:
            return .relays
        case .highJump, .poleVault, .longJump, .tripleJump:
            return .jumps
        case .shotPut, .discus, .hammer, .javelin:
            return .throws
        case .heptathlon, .decathlon:
            return .combinedEvents
        case .raceWalk20k, .raceWalk35k:
            return .raceWalk
        case .fiveK, .tenK, .halfMarathon, .marathon:
            return .roadRunning
        case .crossCountry:
            return .crossCountry
        case .m60:
            return .indoorOnly
        }
    }

    var isMixed: Bool {
        self == .relayMixed4x400 || self == .relayMixed4x100
    }

    var isIndoorOnly: Bool {
        self == .m60
    }

    var isOlympicEvent: Bool {
        switch self {
        case .m100, .m200, .m400, .m800, .m1500, .m5000, .m10000, .sc3000,
             .h100, .h110, .h400,
             .relay4x100, .relay4x400, .relayMixed4x400,
             .highJump, .poleVault, .longJump, .tripleJump,
             .shotPut, .discus, .hammer, .javelin,
             .heptathlon, .decathlon,
             .raceWalk20k, .marathon:
            return true
        default:
            return false
        }
    }

    /// Lookup by raw value string, case-insensitive.
    static func from(_ string: String) -> TrackEvent? {
        TrackEvent.allCases.first {
            $0.rawValue.lowercased() == string.lowercased()
        }
    }
}
