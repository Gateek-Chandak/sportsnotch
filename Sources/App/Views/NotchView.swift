import SwiftUI

struct NotchView: View {
    let games: [Game]
    let metrics: NotchMetrics

    @State private var expanded: Bool
    @State private var index: Int

    private let horizontalMargin: CGFloat = 12

    init(games: [Game], metrics: NotchMetrics, expanded: Bool = false) {
        self.games = games
        self.metrics = metrics
        self._expanded = State(initialValue: expanded)
        self._index = State(initialValue: games.firstIndex(where: \.isLive) ?? 0)
    }

    private var game: Game {
        games[min(max(index, 0), games.count - 1)]
    }

    private var colors: (away: Color, home: Color) {
        teamColors(
            awayColor: game.awayColor, awayAltColor: game.awayAltColor,
            homeColor: game.homeColor, homeAltColor: game.homeAltColor
        )
    }

    private var earWidth: CGFloat {
        expanded ? metrics.expandedEar : metrics.collapsedEar
    }

    private func advance(by delta: Int) {
        guard games.count > 1 else { return }
        withAnimation(.snappy(duration: 0.25)) {
            index = (index + delta + games.count) % games.count
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear.allowsHitTesting(false)

            VStack(spacing: 0) {
                topBar
                if expanded {
                    detailPanel
                        .transition(.scale(scale: 0.85, anchor: .top).combined(with: .opacity))
                }
            }
            .background(notchShape.fill(backgroundGradient))
            .overlay(notchShape.strokeBorder(.white.opacity(0.08), lineWidth: 0.5))
            .clipShape(notchShape)
            .shadow(color: .black.opacity(expanded ? 0.45 : 0), radius: 16, y: 9)
            .onHover { hovering in
                withAnimation(.snappy(duration: 0.32, extraBounce: 0.06)) {
                    expanded = hovering
                }
            }
        }
        .frame(width: metrics.windowWidth, height: metrics.windowHeight, alignment: .top)
    }

    private var topBar: some View {
        HStack(spacing: 0) {
            teamTag(abbreviation: game.awayAbbreviation, score: game.awayScore, color: colors.away, isAway: true)
            Color.clear.frame(width: metrics.notchWidth)
            teamTag(abbreviation: game.homeAbbreviation, score: game.homeScore, color: colors.home, isAway: false)
        }
        .frame(height: metrics.notchHeight)
    }

    private func teamTag(abbreviation: String, score: Int, color: Color, isAway: Bool) -> some View {
        let scoreText = Text("\(score)")
            .font(.system(size: 14, weight: .medium))
            .monospacedDigit()
            .foregroundStyle(color)
            .scaleEffect(expanded ? 1 : 0.9, anchor: isAway ? .trailing : .leading)
        let abbreviationText = Text(abbreviation)
            .font(.system(size: 13))
            .tracking(0.5)
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(.white.opacity(0.75))

        return HStack(spacing: 0) {
            if expanded {
                if isAway {
                    abbreviationText
                    Spacer(minLength: 6)
                    scoreText
                } else {
                    scoreText
                    Spacer(minLength: 6)
                    abbreviationText
                }
            } else {
                scoreText
            }
        }
        .padding(isAway ? .leading : .trailing, expanded ? horizontalMargin : 0)
        .frame(width: earWidth, height: metrics.notchHeight, alignment: isAway ? .trailing : .leading)
        .clipped()
    }

    private var detailPanel: some View {
        VStack(spacing: 6) {
            statusRow

            if !game.goals.isEmpty {
                divider
                VStack(spacing: 6) {
                    ForEach(game.goals, content: goalLine)
                }
            }
        }
        .padding(.horizontal, horizontalMargin)
        .padding(.bottom, 13)
        .frame(width: metrics.windowWidth)
    }

    private var statusRow: some View {
        HStack(spacing: 0) {
            NavigationArrow(symbol: "chevron.left", alignment: .leading, enabled: games.count > 1) { advance(by: -1) }
            Spacer()
            Text(game.status)
                .font(.system(size: 13, weight: .medium))
                .tracking(0.8)
                .foregroundStyle(game.isLive ? .green : .white.opacity(0.4))
            Spacer()
            NavigationArrow(symbol: "chevron.right", alignment: .trailing, enabled: games.count > 1) { advance(by: 1) }
        }
    }

    private var divider: some View {
        LinearGradient(
            colors: [.clear, .white.opacity(0.14), .clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
        .padding(.horizontal, 74)
        .padding(.bottom, 6)
    }

    private func goalLine(_ goal: Goal) -> some View {
        HStack(spacing: 7) {
            Circle()
                .fill(goal.isHome ? colors.home : colors.away)
                .frame(width: 5, height: 5)

            Text(goal.scorer)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.92))

            if let badge = goal.kind.badge {
                badgeChip(badge, tint: badgeTint(goal.kind))
            }

            Spacer(minLength: 8)

            Text(goal.minute)
                .font(.system(size: 9))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private func badgeChip(_ text: String, tint: Color) -> some View {
        let chip = RoundedRectangle(cornerRadius: 4, style: .continuous)
        return Text(text)
            .font(.system(size: 8))
            .tracking(0.5)
            .foregroundStyle(tint)
            .padding(.horizontal, 5)
            .padding(.vertical, 1.5)
            .background(chip.fill(tint.opacity(0.16)))
            .overlay(chip.strokeBorder(tint.opacity(0.3), lineWidth: 0.5))
    }

    private func badgeTint(_ kind: GoalKind) -> Color {
        switch kind {
        case .penalty: return Color(hex: "FFB020")
        case .ownGoal: return Color(hex: "FF5A5A")
        case .normal: return .white
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(white: 0), Color(white: 0.06)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var notchShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(bottomLeadingRadius: 18, bottomTrailingRadius: 18, style: .continuous)
    }
}
