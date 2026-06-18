import SwiftUI

struct NotchMetrics {
    let notchWidth: CGFloat
    let notchHeight: CGFloat
    let collapsedEar: CGFloat
    let expandedEar: CGFloat
    var windowHeight: CGFloat = 270

    var windowWidth: CGFloat { notchWidth + expandedEar * 2 }
}

extension NotchMetrics {
    static let sample = NotchMetrics(
        notchWidth: 190, notchHeight: 37, collapsedEar: 16, expandedEar: 58
    )
}

struct NotchView: View {
    let games: [Game]
    let metrics: NotchMetrics

    @State private var expanded: Bool
    @State private var index: Int

    init(games: [Game], metrics: NotchMetrics, expanded: Bool = false) {
        self.games = games
        self.metrics = metrics
        self._expanded = State(initialValue: expanded)
        self._index = State(initialValue: games.firstIndex(where: { $0.isLive }) ?? 0)
    }

    private var game: Game {
        guard !games.isEmpty else { return .sample }
        return games[min(max(index, 0), games.count - 1)]
    }

    private var dots: (away: Color, home: Color) {
        teamDotColors(
            awayColor: game.awayColor, awayAltColor: game.awayAltColor,
            homeColor: game.homeColor, homeAltColor: game.homeAltColor
        )
    }

    private var earWidth: CGFloat {
        expanded ? metrics.expandedEar : metrics.collapsedEar
    }

    private let horizontalMargin: CGFloat = 12

    private func step(_ delta: Int) {
        guard games.count > 1 else { return }
        withAnimation(.snappy(duration: 0.25)) {
            index = (index + delta + games.count) % games.count
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                topBar
                if expanded {
                    detailPanel
                        .transition(.scale(scale: 0.85, anchor: .top).combined(with: .opacity))
                }
            }
            .background(shape.fill(background))
            .overlay(shape.strokeBorder(.white.opacity(0.08), lineWidth: 0.5))
            .clipShape(shape)
            .shadow(color: .black.opacity(expanded ? 0.45 : 0), radius: 16, y: 9)
            .onHover { hovering in
                withAnimation(.snappy(duration: 0.32, extraBounce: 0.06)) {
                    expanded = hovering
                }
            }
        }
        .frame(width: metrics.windowWidth, height: metrics.windowHeight, alignment: .top)
    }

    private var background: LinearGradient {
        LinearGradient(
            colors: [Color(white: 0.0), Color(white: 0.06)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var topBar: some View {
        HStack(spacing: 0) {
            teamTag(abbr: game.awayAbbr, score: game.awayScore, color: dots.away, isAway: true)
            Color.clear.frame(width: metrics.notchWidth)
            teamTag(abbr: game.homeAbbr, score: game.homeScore, color: dots.home, isAway: false)
        }
        .frame(height: metrics.notchHeight)
    }

    private func teamTag(abbr: String, score: Int, color: Color, isAway: Bool) -> some View {
        let scoreText = Text("\(score)")
            .font(.system(size: 14, weight: .medium))
            .monospacedDigit()
            .foregroundStyle(color)
            .scaleEffect(expanded ? 1 : 0.90, anchor: isAway ? .trailing : .leading)
        let abbrText = Text(abbr)
            .font(.system(size: 13, weight: .regular))
            .tracking(0.5)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .foregroundStyle(.white.opacity(0.75))

        return HStack(spacing: 0) {
            if expanded {
                if isAway {
                    abbrText
                    Spacer(minLength: 6)
                    scoreText
                } else {
                    scoreText
                    Spacer(minLength: 6)
                    abbrText
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
        VStack(spacing: 11) {
            statusRow

            if !game.goals.isEmpty {
                LinearGradient(
                    colors: [.clear, .white.opacity(0.14), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
                .padding(.horizontal, 74)
                .padding(.bottom, 6)

                VStack(spacing: 6) {
                    ForEach(game.goals) { goal in
                        goalLine(goal)
                    }
                }
            }
        }
        .padding(.horizontal, horizontalMargin)
        .padding(.bottom, 13)
        .frame(width: metrics.windowWidth)
    }

    private var statusRow: some View {
        HStack(spacing: 0) {
            NavArrow(system: "chevron.left", alignment: .leading, enabled: games.count > 1) { step(-1) }

            Spacer()
            Text(game.status)
                .font(.system(size: 13, weight: .medium))
                .tracking(0.8)
                .foregroundStyle(game.isLive ? .green : .white.opacity(0.4))
            Spacer()

            NavArrow(system: "chevron.right", alignment: .trailing, enabled: games.count > 1) { step(1) }
        }
    }

    private func goalLine(_ goal: Goal) -> some View {
        HStack(spacing: 7) {
            Circle()
                .fill(goal.isHome ? dots.home : dots.away)
                .frame(width: 5, height: 5)

            Text(goal.scorer)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.92))

            if let badge = goal.kind.badge {
                let tint = badgeTint(goal.kind)
                Text(badge)
                    .font(.system(size: 8, weight: .regular))
                    .tracking(0.5)
                    .foregroundStyle(tint)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1.5)
                    .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(tint.opacity(0.16)))
                    .overlay(RoundedRectangle(cornerRadius: 4, style: .continuous).strokeBorder(tint.opacity(0.3), lineWidth: 0.5))
            }

            Spacer(minLength: 8)

            Text(goal.minute)
                .font(.system(size: 9, weight: .regular))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private func badgeTint(_ kind: GoalKind) -> Color {
        switch kind {
        case .penalty: return Color(hex: "FFB020")
        case .ownGoal: return Color(hex: "FF5A5A")
        case .normal: return .white
        }
    }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            bottomLeadingRadius: 18,
            bottomTrailingRadius: 18,
            style: .continuous
        )
    }
}

private struct NavArrow: View {
    let system: String
    let alignment: Alignment
    let enabled: Bool
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Image(systemName: system)
            .font(.system(size: 11, weight: .regular))
            .foregroundStyle(.white.opacity(enabled ? (hovering ? 1 : 0.5) : 0.15))
            .frame(width: 26, height: 22, alignment: alignment)
            .contentShape(Rectangle())
            .onHover { h in
                withAnimation(.easeOut(duration: 0.15)) { hovering = enabled && h }
            }
            .onTapGesture(perform: action)
    }
}

#Preview("Day") {
    NotchView(games: Game.today, metrics: .sample, expanded: true)
        .padding(40)
        .background(.gray)
}
