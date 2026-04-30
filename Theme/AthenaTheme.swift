import SwiftUI

enum AthenaTheme {
    static let charcoal = Color(red: 0.17, green: 0.11, blue: 0.28)
    static let graphite = Color(red: 0.29, green: 0.20, blue: 0.45)
    static let panel = Color(red: 0.41, green: 0.30, blue: 0.64)
    static let panelRaised = Color(red: 0.56, green: 0.42, blue: 0.82)
    static let bone = Color(red: 1.00, green: 0.99, blue: 1.00)
    static let stone = Color(red: 0.93, green: 0.88, blue: 0.98)
    // Keep existing property names to avoid touching feature code.
    static let teal = Color(red: 0.98, green: 0.41, blue: 0.80)      // luminous orchid accent
    static let tealMuted = Color(red: 0.79, green: 0.72, blue: 0.98) // soft lilac accent
    static let lavender = Color(red: 0.77, green: 0.64, blue: 0.98)
    static let magenta = Color(red: 0.92, green: 0.34, blue: 0.77)
    static let ink = Color(red: 0.13, green: 0.10, blue: 0.20)
    static let inkMuted = Color(red: 0.33, green: 0.28, blue: 0.44)
    static let alert = Color(red: 0.98, green: 0.43, blue: 0.37)
    static let divider = Color.white.opacity(0.20)

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 1.00, green: 1.00, blue: 1.00),
            Color(red: 0.98, green: 0.95, blue: 1.00),
            lavender.opacity(0.30)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let luxePanelGradient = LinearGradient(
        colors: [
            panelRaised,
            panel,
            graphite
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
                        .stroke(AthenaTheme.tealMuted.opacity(0.30), lineWidth: 3)
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
                        .stroke(AthenaTheme.magenta.opacity(0.28), lineWidth: 4)
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
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AthenaTheme.panelRaised, AthenaTheme.graphite],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                        .stroke(AthenaTheme.teal.opacity(0.32), lineWidth: 1)
                )

            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height

                ZStack {
                    Circle()
                        .trim(from: 0.10, to: 0.86)
                        .stroke(AthenaTheme.teal.opacity(0.85), lineWidth: w * 0.05)
                        .frame(width: w * 0.88, height: h * 0.88)

                    Path { path in
                        path.move(to: CGPoint(x: w * 0.23, y: h * 0.82))
                        path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.18))
                        path.addLine(to: CGPoint(x: w * 0.77, y: h * 0.82))
                    }
                    .stroke(Color.white, style: StrokeStyle(lineWidth: w * 0.125, lineCap: .round, lineJoin: .round))

                    Path { path in
                        path.move(to: CGPoint(x: w * 0.36, y: h * 0.55))
                        path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.55))
                    }
                    .stroke(AthenaTheme.tealMuted, style: StrokeStyle(lineWidth: w * 0.085, lineCap: .round))

                    Ellipse()
                        .fill(AthenaTheme.bone)
                        .frame(width: w * 0.18, height: h * 0.10)
                        .offset(y: -h * 0.05)

                    Circle()
                        .fill(AthenaTheme.charcoal)
                        .frame(width: w * 0.05)
                        .offset(y: -h * 0.05)
                }
            }
            .padding(size * 0.16)
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
    var eyebrow: String? = nil
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
                AthenaMark(size: 54)

                VStack(alignment: .leading, spacing: 6) {
                    if let eyebrow {
                        Text(eyebrow.uppercased())
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AthenaTheme.teal)
                    }

                    Text(title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AthenaTheme.bone)

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
                .fill(AthenaTheme.luxePanelGradient.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AthenaTheme.teal.opacity(0.22), lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.26), Color.white.opacity(0.00)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blur(radius: 0.4)
                    , alignment: .topLeading
                )
        )
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
                            .stroke(AthenaTheme.teal.opacity(0.26), lineWidth: 1)
                    )
            )
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
                            .stroke(AthenaTheme.teal.opacity(0.20), lineWidth: 1)
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
    }
}

extension View {
    func athenaCard() -> some View {
        modifier(AthenaCardModifier())
    }
}