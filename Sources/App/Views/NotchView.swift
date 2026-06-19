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

    private var statusText: String {
        guard game.isFinished else { return game.status }
        if game.awayScore > game.homeScore { return "\(game.awayAbbreviation) Won" }
        if game.homeScore > game.awayScore { return "\(game.homeAbbreviation) Won" }
        return "Draw"
    }

    private var statusColor: Color {
        (game.isFinished || game.isLive) ? .white : .white.opacity(0.4)
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
                        .transition(.opacity)
                }
            }
            .background(notchShape.fill(backgroundGradient))
            .clipShape(notchShape)
            .onHover { hovering in
                let animation: Animation = hovering
                    ? .snappy(duration: 0.32, extraBounce: 0.06)
                    : .smooth(duration: 0.25)
                withAnimation(animation) {
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
            .font(.geist(size: 14, weight: .medium))
            .monospacedDigit()
            .fixedSize()
            .foregroundStyle(color)
            .scaleEffect(expanded ? 1 : 0.9, anchor: isAway ? .trailing : .leading)
        let abbreviationText = Text(abbreviation)
            .font(.geist(size: 14))
            .tracking(0.5)
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(.white.opacity(0.85))

        return HStack(spacing: 0) {
            if expanded {
                if isAway {
                    abbreviationText
                    Spacer(minLength: 4)
                    scoreText
                } else {
                    scoreText
                    Spacer(minLength: 4)
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
            recordsRow
            statusRow

            if !game.events.isEmpty {
                VStack(spacing: 6) {
                    ForEach(game.events, content: eventLine)
                }
                .padding(.top, 10)
            }

            if !game.stats.isEmpty {
                VStack(spacing: 7) {
                    ForEach(game.stats, content: statLine)
                }
                .padding(.top, 10)
            }

            footer
                .padding(.top, 12)
        }
        .padding(.top, 5)
        .padding(.horizontal, horizontalMargin)
        .padding(.bottom, 13)
        .frame(width: metrics.windowWidth)
    }

    private var recordsRow: some View {
        HStack(spacing: 0) {
            Text(game.awayRecord)
            Spacer()
            Text(game.homeRecord)
        }
        .font(.geist(size: 8))
        .monospacedDigit()
        .foregroundStyle(.white.opacity(0.4))
        .padding(.top, -8)
    }

    private var statusRow: some View {
        HStack(spacing: 0) {
            NavigationArrow(symbol: "chevron.left", alignment: .leading, enabled: games.count > 1) { advance(by: -1) }
            Spacer()
            Text(statusText)
                .font(.geist(size: 13, weight: .medium))
                .tracking(0.8)
                .monospacedDigit()
                .foregroundStyle(statusColor)
            Spacer()
            NavigationArrow(symbol: "chevron.right", alignment: .trailing, enabled: games.count > 1) { advance(by: 1) }
        }
    }

    private func eventLine(_ event: MatchEvent) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(event.isHome ? colors.home : colors.away)
                .frame(width: 5, height: 5)

            Text(event.player)
                .font(.geist(size: 11))
                .foregroundStyle(.white.opacity(0.92))

            eventTypeIndicator(event)

            Spacer(minLength: 8)

            Text(event.minute)
                .font(.geist(size: 9))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 40, alignment: .trailing)
        }
    }

    @ViewBuilder
    private func eventTypeIndicator(_ event: MatchEvent) -> some View {
        switch event.kind {
        case .goal:
            goalIcon
        case .penalty:
            typeLabel("Penalty")
        case .ownGoal:
            typeLabel("Own Goal")
        case .yellowCard:
            cardShape(Color(hex: "FFCC00"))
        case .redCard:
            cardShape(Color(hex: "FF3B30"))
        }
    }

    private var goalIcon: some View {
        Image(systemName: "soccerball")
            .font(.system(size: 9))
            .foregroundStyle(.white.opacity(0.7))
    }

    private func typeLabel(_ text: String) -> some View {
        HStack(spacing: 3) {
            goalIcon
            Text(text)
                .font(.geist(size: 8))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private func cardShape(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(color)
            .frame(width: 6, height: 9)
    }

    private func statLine(_ stat: TeamStat) -> some View {
        let awayValue = numericValue(stat.away)
        let homeValue = numericValue(stat.home)
        let total = awayValue + homeValue
        let awayFraction = total > 0 ? awayValue / total : 0.5

        return VStack(spacing: 3) {
            HStack(spacing: 0) {
                Text(stat.away)
                    .frame(width: 40, alignment: .leading)
                Spacer()
                Text(stat.label)
                    .foregroundStyle(.white.opacity(0.4))
                Spacer()
                Text(stat.home)
                    .frame(width: 40, alignment: .trailing)
            }
            .font(.geist(size: 9))
            .monospacedDigit()
            .foregroundStyle(.white.opacity(0.75))

            GeometryReader { geo in
                HStack(spacing: 2) {
                    Capsule()
                        .fill(colors.away)
                        .frame(width: max(2, (geo.size.width - 2) * awayFraction))
                    Capsule()
                        .fill(colors.home)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 3)
        }
    }

    private func numericValue(_ string: String) -> Double {
        Double(string.filter { $0.isNumber || $0 == "." }) ?? 0
    }

    private var footer: some View {
        HStack(spacing: 5) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 7))
            Text("FIFA WORLD CUP 2026")
                .font(.geist(size: 8, weight: .medium))
                .tracking(0.4)
        }
        .foregroundStyle(
            LinearGradient(
                colors: [Color(hex: "C9A227"), Color(hex: "F2D98D")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .opacity(0.6)
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
