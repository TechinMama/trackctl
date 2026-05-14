import SwiftUI

enum AthenaTheme {
    static let charcoal = Color(red: 0.05, green: 0.05, blue: 0.08)
    static let graphite = Color(red: 0.12, green: 0.10, blue: 0.18)
    static let panel = Color(red: 0.19, green: 0.15, blue: 0.28)
    static let panelRaised = Color(red: 0.30, green: 0.23, blue: 0.43)
    static let bone = Color(red: 0.96, green: 0.95, blue: 0.97)
    static let stone = Color(red: 0.80, green: 0.79, blue: 0.84)
    // Keep existing property names to avoid touching feature code.
    static let teal = Color(red: 0.95, green: 0.74, blue: 0.34)      // metallic gold accent
    static let tealMuted = Color(red: 0.84, green: 0.82, blue: 0.88) // silver accent
    static let lavender = Color(red: 0.43, green: 0.33, blue: 0.59)  // plum accent
    static let magenta = Color(red: 0.66, green: 0.51, blue: 0.82)
    static let ink = Color(red: 0.95, green: 0.94, blue: 0.97)
    static let inkMuted = Color(red: 0.78, green: 0.76, blue: 0.82)
    static let alert = Color(red: 0.98, green: 0.43, blue: 0.37)
    static let divider = Color.white.opacity(0.16)

    static let heroGradient = LinearGradient(
        colors: [
            ink,
            graphite,
            panel,
            Color(red: 0.12, green: 0.08, blue: 0.20)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let luxePanelGradient = LinearGradient(
        colors: [
            Color(red: 0.38, green: 0.30, blue: 0.54),
            panelRaised,
            panel,
            graphite,
            charcoal
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct AthenaBackdrop: View {
    var body: some View {
        ZStack {
            AthenaTheme.heroGradient
                .ignoresSafeArea()

            VStack {
                HStack {
                    Circle()
                        .trim(from: 0.08, to: 0.74)
                        .stroke(AthenaTheme.teal.opacity(0.24), lineWidth: 3)
                        .frame(width: 220, height: 220)
                        .offset(x: -90, y: -80)
                    Spacer()
                }
                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .trim(from: 0.16, to: 0.86)
                        .stroke(AthenaTheme.tealMuted.opacity(0.24), lineWidth: 4)
                        .frame(width: 260, height: 260)
                        .offset(x: 100, y: 120)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct AthenaMark: View {
    var size: CGFloat = 44

    var body: some View {
        Image("AthenaMark")
            .resizable()
            .renderingMode(.original)
            .interpolation(.high)
            .antialiased(true)
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

struct AthenaMiniMark: View {
    var size: CGFloat = 14
    
    private struct Metrics {
        let cornerRatio: CGFloat
        let borderWidthRatio: CGFloat
        let ringTrimStart: CGFloat
        let ringTrimEnd: CGFloat
        let ringLineWidthRatio: CGFloat
        let ringFrameRatio: CGFloat
        let aLineWidthRatio: CGFloat
        let aLineWidthMinimum: CGFloat
        let barLineWidthRatio: CGFloat
        let barLineWidthMinimum: CGFloat
        let paddingRatio: CGFloat
    }
    
    private var metrics: Metrics {
        switch size {
        case ..<13:
            return Metrics(
                cornerRatio: 0.23,
                borderWidthRatio: 0.06,
                ringTrimStart: 0.16,
                ringTrimEnd: 0.82,
                ringLineWidthRatio: 0.08,
                ringFrameRatio: 0.82,
                aLineWidthRatio: 0.14,
                aLineWidthMinimum: 1.4,
                barLineWidthRatio: 0.09,
                barLineWidthMinimum: 1.1,
                paddingRatio: 0.15
            )
        case ..<15:
            return Metrics(
                cornerRatio: 0.24,
                borderWidthRatio: 0.07,
                ringTrimStart: 0.14,
                ringTrimEnd: 0.84,
                ringLineWidthRatio: 0.09,
                ringFrameRatio: 0.84,
                aLineWidthRatio: 0.15,
                aLineWidthMinimum: 1.6,
                barLineWidthRatio: 0.10,
                barLineWidthMinimum: 1.2,
                paddingRatio: 0.16
            )
        default:
            return Metrics(
                cornerRatio: 0.24,
                borderWidthRatio: 0.075,
                ringTrimStart: 0.13,
                ringTrimEnd: 0.85,
                ringLineWidthRatio: 0.095,
                ringFrameRatio: 0.85,
                aLineWidthRatio: 0.155,
                aLineWidthMinimum: 1.8,
                barLineWidthRatio: 0.105,
                barLineWidthMinimum: 1.3,
                paddingRatio: 0.16
            )
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * metrics.cornerRatio, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AthenaTheme.panelRaised, AthenaTheme.graphite],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * metrics.cornerRatio, style: .continuous)
                        .stroke(AthenaTheme.teal.opacity(0.38), lineWidth: max(1, size * metrics.borderWidthRatio))
                )

            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height

                ZStack {
                    Circle()
                        .trim(from: metrics.ringTrimStart, to: metrics.ringTrimEnd)
                        .stroke(AthenaTheme.teal.opacity(0.95), lineWidth: max(1, width * metrics.ringLineWidthRatio))
                        .frame(width: width * metrics.ringFrameRatio, height: height * metrics.ringFrameRatio)

                    Path { path in
                        path.move(to: CGPoint(x: width * 0.26, y: height * 0.79))
                        path.addLine(to: CGPoint(x: width * 0.50, y: height * 0.24))
                        path.addLine(to: CGPoint(x: width * 0.74, y: height * 0.79))
                    }
                    .stroke(
                        Color.white,
                        style: StrokeStyle(
                            lineWidth: max(metrics.aLineWidthMinimum, width * metrics.aLineWidthRatio),
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )

                    Path { path in
                        path.move(to: CGPoint(x: width * 0.38, y: height * 0.56))
                        path.addLine(to: CGPoint(x: width * 0.62, y: height * 0.56))
                    }
                    .stroke(
                        AthenaTheme.tealMuted,
                        style: StrokeStyle(
                            lineWidth: max(metrics.barLineWidthMinimum, width * metrics.barLineWidthRatio),
                            lineCap: .round
                        )
                    )
                }
            }
            .padding(size * metrics.paddingRatio)
        }
        .frame(width: size, height: size)
    }
}

struct AthenaHeroHeader: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    struct PillItem {
        let label: String
        let systemImage: String
    }

    let title: String
    let subtitle: String
    var eyebrow: String?
    var pills: [PillItem] = [
        PillItem(label: "Intelligent", systemImage: "brain"),
        PillItem(label: "Insightful", systemImage: "eye.fill"),
        PillItem(label: "Analytical", systemImage: "chart.xyaxis.line"),
        PillItem(label: "Performant", systemImage: "gauge.with.dots.needle.67percent"),
        PillItem(label: "Fast", systemImage: "bolt.fill")
    ]

    private var isCompactWidth: Bool {
        horizontalSizeClass == .compact
    }

    private var visiblePills: [PillItem] {
        isCompactWidth ? Array(pills.prefix(3)) : pills
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                AthenaMark(size: 72)

                VStack(alignment: .leading, spacing: 6) {
                    if let eyebrow {
                        Text(eyebrow.uppercased())
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AthenaTheme.teal)
                    }

                    Text(title)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .tracking(0.3)
                        .foregroundStyle(AthenaTheme.bone)
                        .lineLimit(2)
                        .minimumScaleFactor(0.92)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AthenaTheme.stone)
                }
            }

            if isCompactWidth {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 104), spacing: 8, alignment: .leading)],
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(visiblePills, id: \.label) { pill in
                        AthenaPill(label: pill.label, systemImage: pill.systemImage, compact: true)
                    }
                }
            } else {
                HStack(spacing: 10) {
                    ForEach(visiblePills, id: \.label) { pill in
                        AthenaPill(label: pill.label, systemImage: pill.systemImage)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AthenaTheme.luxePanelGradient.opacity(0.98))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AthenaTheme.teal.opacity(0.30), lineWidth: 1.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.24), Color.white.opacity(0.00)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blur(radius: 0.4)
                    , alignment: .topLeading
                )
        )
        .shadow(color: Color.black.opacity(0.30), radius: 16, x: 0, y: 10)
    }
}

struct AthenaPill: View {
    let label: String
    let systemImage: String
    var compact: Bool = false

    var body: some View {
        Label(label, systemImage: systemImage)
            .font((compact ? Font.caption2 : Font.caption).weight(.semibold))
            .foregroundStyle(AthenaTheme.bone)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, compact ? 9 : 12)
            .padding(.vertical, compact ? 6 : 7)
            .background(
                Capsule(style: .continuous)
                    .fill(AthenaTheme.luxePanelGradient)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(AthenaTheme.teal.opacity(0.34), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.24), radius: 4, x: 0, y: 2)
    }
}

struct AthenaSectionHeader: View {
    let title: String
    let detail: String?
    var onLightBackground: Bool

    init(_ title: String, detail: String? = nil, onLightBackground: Bool = false) {
        self.title = title
        self.detail = detail
        self.onLightBackground = onLightBackground
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(onLightBackground ? AthenaTheme.ink : AthenaTheme.bone)
            if let detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(onLightBackground ? AthenaTheme.inkMuted : AthenaTheme.stone)
            }
        }
    }
}

struct AthenaCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AthenaTheme.luxePanelGradient.opacity(0.97))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AthenaTheme.teal.opacity(0.28), lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.22), Color.white.opacity(0.00)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blendMode(.screen)
                        , alignment: .topLeading
                    )
            )
            .shadow(color: Color.black.opacity(0.26), radius: 10, x: 0, y: 6)
    }
}

extension View {
    func athenaCard() -> some View {
        modifier(AthenaCardModifier())
    }
}
