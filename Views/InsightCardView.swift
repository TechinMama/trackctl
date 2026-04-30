import SwiftUI

// MARK: - AI Insight card matching storyboard Scene 4.
// Shows the explanation text, source badge, and citation line.

struct InsightCardView: View {
    let text: String
    let citations: [String]
    let isLoading: Bool
    let source: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AthenaTheme.teal)
                Text("AI Performance Insight")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AthenaTheme.teal)
                Spacer()
                SourceBadge(source: source)
            }

            if isLoading {
                HStack {
                    ProgressView()
                        .tint(AthenaTheme.teal)
                        .scaleEffect(0.8)
                    Text("Generating insight…")
                        .font(.subheadline)
                        .foregroundStyle(AthenaTheme.stone)
                }
            } else {
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(AthenaTheme.bone)
                    .lineSpacing(4)
            }

            if !citations.isEmpty && !isLoading {
                Divider()
                    .background(AthenaTheme.graphite)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Source context")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(AthenaTheme.stone)
                    Text(citations.joined(separator: " · "))
                        .font(.caption2)
                        .foregroundStyle(AthenaTheme.inkMuted)
                }
            }
        }
        .padding()
        .athenaCard()
    }
}

private struct SourceBadge: View {
    let source: String

    var body: some View {
        Text(source == "huggingface" ? "AI" : "Deterministic")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(AthenaTheme.bone)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule(style: .continuous)
                    .fill(source == "huggingface" ? AthenaTheme.teal.opacity(0.25) : AthenaTheme.graphite)
            )
    }
}

#Preview {
    VStack(spacing: 16) {
        InsightCardView(
            text: "McLaughlin-Levrone's 50.65 signals she's tracking toward another world record attempt. Her season opener pace is faster than her 2023 campaign at the same point—a historically significant benchmark.",
            citations: ["World Athletics", "FloTrack"],
            isLoading: false,
            source: "deterministic"
        )
        InsightCardView(
            text: "",
            citations: [],
            isLoading: true,
            source: "deterministic"
        )
    }
    .padding()
    .background(AthenaTheme.ink)
}
