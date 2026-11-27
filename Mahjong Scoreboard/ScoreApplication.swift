import Foundation

struct RoundHistoryEntry: Identifiable {
    enum Result {
        case ron(winner: String, loser: String, han: Int, fu: Int, points: Int)
        case tsumo(winner: String, han: Int, fu: Int, points: Int)
        case multipleRon(MultipleRonBreakdown, honbaCount: Int, threePlayerMode: Bool)
        case exhaustiveDraw
    }

    let id = UUID()
    let round: String
    private let playersAtResult: [Player]
    private let activeCount: Int
    private let result: Result
    private let plan: ScoreApplicationPlan
    let playersBeforeRound: [Player]
    let windsBeforeRound: [String]
    let roundWind: String
    let extraRounds: Bool
    let honbaCount: Int
    let riichiPotBeforeRound: Int

    init(players: [Player], winds: [String], roundWind: String, extraRounds: Bool,
         honbaCount: Int, riichiPot: Int, threePlayerMode: Bool,
         result: Result, plan: ScoreApplicationPlan) {
        let activeCount = threePlayerMode ? 3 : players.count
        let activePlayers = Array(players.prefix(activeCount))
        let windNames = ["東": "East", "南": "South", "西": "West", "北": "North"]
        let dealerIndex = activePlayers.firstIndex(where: { $0.wind == "東" }) ?? 0
        let roundName = "\(windNames[roundWind] ?? roundWind) \(dealerIndex + 1)"
        round = honbaCount > 0 ? "\(roundName) - \(honbaCount) honba" : roundName
        playersAtResult = players
        self.activeCount = activeCount
        self.result = result
        self.plan = plan
        playersBeforeRound = players.enumerated().map { index, player in
            var restored = player
            if index < activeCount && restored.riichi { restored.score += 1000 }
            restored.winner = false
            restored.loser = false
            restored.riichi = false
            restored.tenpai = false
            restored.multRonWin = false
            restored.han = 1
            restored.fu = 20
            return restored
        }
        windsBeforeRound = winds
        self.roundWind = roundWind
        self.extraRounds = extraRounds
        self.honbaCount = honbaCount
        riichiPotBeforeRound = riichiPot - activePlayers.filter(\.riichi).count * 1000
    }

    private func label(_ player: Player, currentPlayers: [Player]) -> String {
        let name = currentPlayers.first(where: { $0.id == player.id })?.name ?? player.name
        return "\(name) (\(player.wind))"
    }

    private func pointsText(_ points: Int) -> String {
        points.formatted(.number.grouping(.automatic))
    }

    func summary(currentPlayers: [Player]) -> [String] {
        func playerLabel(_ wind: String) -> String {
            playersAtResult.prefix(activeCount).first(where: { $0.wind == wind })
                .map { label($0, currentPlayers: currentPlayers) } ?? wind
        }
        switch result {
        case let .ron(winner, loser, han, fu, points):
            return ["\(playerLabel(winner)) ron \(playerLabel(loser)) / \(han) han/\(fu) fu / \(pointsText(points))"]
        case let .tsumo(winner, han, fu, points):
            return ["\(playerLabel(winner)) tsumo / \(han) han/\(fu) fu / \(pointsText(points))"]
        case let .multipleRon(breakdown, honbaCount, threePlayerMode):
            return breakdown.orderedWinnerIndices.map { index in
                let player = playersAtResult[index]
                let points = HandScoring.calculateRon(winnerWind: player.wind, han: player.han, fu: player.fu,
                                                       honbaCount: honbaCount, threePlayerMode: threePlayerMode).winnerPoints
                return "\(label(player, currentPlayers: currentPlayers)) ron \(playerLabel(breakdown.loserWind)) / \(player.han) han/\(player.fu) fu / \(pointsText(points))"
            }
        case .exhaustiveDraw:
            return ["Exhaustive draw"]
        }
    }

    func riichiPlayers(currentPlayers: [Player]) -> [String] {
        playersAtResult.prefix(activeCount).filter(\.riichi).map { label($0, currentPlayers: currentPlayers) }
    }

    func changes(currentPlayers: [Player]) -> [String] {
        (0..<activeCount).compactMap { index in
            guard plan.scoreChangesByIndex[index] else { return nil }
            let change = plan.winningPointsByIndex[index] - plan.losingPointsByIndex[index]
            guard change != 0 else { return nil }
            return "\(label(playersAtResult[index], currentPlayers: currentPlayers)): \(change > 0 ? "+" : "−")\(pointsText(abs(change)))"
        }
    }

    func playersBeforeRound(currentPlayers: [Player]) -> [Player] {
        playersBeforeRound.map { player in
            var restored = player
            restored.name = currentPlayers.first(where: { $0.id == player.id })?.name ?? player.name
            return restored
        }
    }
}

struct ScoreApplicationPlan {
    let players: [Player]
    let winningPointsByIndex: [Int]
    let losingPointsByIndex: [Int]
    let scoreChangesByIndex: [Bool]
    let shouldRotateWinds: Bool
    let honbaCount: Int
    let riichiPot: Int
    let riichiPotIndicator: Int
    let han: Int
    let fu: Int
    let addingFu: Int
    let wasRon: Bool
    let wasTsumo: Bool
    let selectedLoser: String?
}

enum ScoreApplication {
    static func tsumo(
        players: [Player],
        winnerPoints: Int,
        dealerPayment: Int,
        nonDealerPayment: Int,
        riichiPot: Int,
        honbaCount: Int,
        threePlayerMode: Bool
    ) -> ScoreApplicationPlan {
        var updatedPlayers = players
        var winningPointsByIndex = Array(repeating: 0, count: players.count)
        var losingPointsByIndex = Array(repeating: 0, count: players.count)
        var scoreChangesByIndex = Array(repeating: false, count: players.count)

        let nextHonbaCount = updatedPlayers.contains(where: { $0.winner && $0.wind == "東" }) ? (honbaCount + 1) : 0

        for i in updatedPlayers.indices {
            if threePlayerMode && i == 3 {
                updatedPlayers[i].winner = false
                updatedPlayers[i].loser = false
                updatedPlayers[i].riichi = false
                updatedPlayers[i].tenpai = false
                continue
            }

            if updatedPlayers[i].winner {
                winningPointsByIndex[i] = winnerPoints + riichiPot
                scoreChangesByIndex[i] = true
                updatedPlayers[i].loser = false
            } else {
                losingPointsByIndex[i] = updatedPlayers[i].wind == "東" ? dealerPayment : nonDealerPayment
                scoreChangesByIndex[i] = true
                updatedPlayers[i].loser = true
            }

            updatedPlayers[i].riichi = false
            updatedPlayers[i].tenpai = false
        }

        return ScoreApplicationPlan(
            players: updatedPlayers,
            winningPointsByIndex: winningPointsByIndex,
            losingPointsByIndex: losingPointsByIndex,
            scoreChangesByIndex: scoreChangesByIndex,
            shouldRotateWinds: !players.contains(where: { $0.winner && $0.wind == "東" }),
            honbaCount: nextHonbaCount,
            riichiPot: 0,
            riichiPotIndicator: 0,
            han: 1,
            fu: 20,
            addingFu: 20,
            wasRon: false,
            wasTsumo: false,
            selectedLoser: nil
        )
    }

    static func ron(
        players: [Player],
        winnerPoints: Int,
        riichiPot: Int,
        winnerWind: String,
        loserWind: String,
        honbaCount: Int
    ) -> ScoreApplicationPlan {
        var updatedPlayers = players
        var winningPointsByIndex = Array(repeating: 0, count: players.count)
        var losingPointsByIndex = Array(repeating: 0, count: players.count)
        var scoreChangesByIndex = Array(repeating: false, count: players.count)

        let nextHonbaCount = winnerWind == "東" ? (honbaCount + 1) : 0

        for i in updatedPlayers.indices {
            if updatedPlayers[i].winner {
                winningPointsByIndex[i] = winnerPoints + riichiPot
                scoreChangesByIndex[i] = true
                updatedPlayers[i].loser = false
            }
            updatedPlayers[i].riichi = false
            updatedPlayers[i].tenpai = false
        }

        if let loserIndex = updatedPlayers.firstIndex(where: { $0.wind == loserWind }) {
            losingPointsByIndex[loserIndex] = winnerPoints
            scoreChangesByIndex[loserIndex] = true
            updatedPlayers[loserIndex].loser = true
        }

        return ScoreApplicationPlan(
            players: updatedPlayers,
            winningPointsByIndex: winningPointsByIndex,
            losingPointsByIndex: losingPointsByIndex,
            scoreChangesByIndex: scoreChangesByIndex,
            shouldRotateWinds: winnerWind != "東",
            honbaCount: nextHonbaCount,
            riichiPot: 0,
            riichiPotIndicator: 0,
            han: 1,
            fu: 20,
            addingFu: 20,
            wasRon: false,
            wasTsumo: false,
            selectedLoser: nil
        )
    }

    static func multipleRon(
        players: [Player],
        breakdown: MultipleRonBreakdown,
        honbaCount: Int
    ) -> ScoreApplicationPlan {
        var updatedPlayers = players
        var winningPointsByIndex = Array(repeating: 0, count: players.count)
        var losingPointsByIndex = Array(repeating: 0, count: players.count)
        var scoreChangesByIndex = Array(repeating: false, count: players.count)

        for i in breakdown.orderedWinnerIndices {
            updatedPlayers[i].winner = true
            winningPointsByIndex[i] = breakdown.winnerPointsByIndex[i]
            scoreChangesByIndex[i] = true
        }

        updatedPlayers[breakdown.loserIndex].loser = true
        losingPointsByIndex[breakdown.loserIndex] = breakdown.totalLoss
        scoreChangesByIndex[breakdown.loserIndex] = true

        for i in updatedPlayers.indices {
            updatedPlayers[i].riichi = false
            updatedPlayers[i].tenpai = false
            updatedPlayers[i].multRonWin = false
            updatedPlayers[i].han = 1
            updatedPlayers[i].fu = 20
        }

        return ScoreApplicationPlan(
            players: updatedPlayers,
            winningPointsByIndex: winningPointsByIndex,
            losingPointsByIndex: losingPointsByIndex,
            scoreChangesByIndex: scoreChangesByIndex,
            shouldRotateWinds: !breakdown.honbaCountWillIncrease,
            honbaCount: breakdown.honbaCountWillIncrease ? (honbaCount + 1) : 0,
            riichiPot: 0,
            riichiPotIndicator: 0,
            han: 1,
            fu: 20,
            addingFu: 20,
            wasRon: false,
            wasTsumo: false,
            selectedLoser: ""
        )
    }

    static func exhaustiveDraw(
        players: [Player],
        tenpaiCount: Int,
        honbaCount: Int,
        riichiPot: Int,
        threePlayerMode: Bool,
        han: Int,
        fu: Int,
        addingFu: Int
    ) -> ScoreApplicationPlan {
        var updatedPlayers = players
        var winningPointsByIndex = Array(repeating: 0, count: players.count)
        var losingPointsByIndex = Array(repeating: 0, count: players.count)
        var scoreChangesByIndex = Array(repeating: false, count: players.count)
        let shouldRotateWinds = !players.contains(where: { $0.wind == "東" && $0.tenpai })

        for i in updatedPlayers.indices {
            updatedPlayers[i].riichi = false
        }

        let nextHonbaCount = honbaCount + 1
        let noPayouts = (threePlayerMode && (tenpaiCount == 0 || tenpaiCount == 3)) || (!threePlayerMode && (tenpaiCount == 0 || tenpaiCount == 4))

        if noPayouts {
            for i in updatedPlayers.indices {
                updatedPlayers[i].tenpai = false
            }
            return ScoreApplicationPlan(
                players: updatedPlayers,
                winningPointsByIndex: winningPointsByIndex,
                losingPointsByIndex: losingPointsByIndex,
                scoreChangesByIndex: scoreChangesByIndex,
                shouldRotateWinds: shouldRotateWinds,
                honbaCount: nextHonbaCount,
                riichiPot: riichiPot,
                riichiPotIndicator: riichiPot / 1000,
                han: han,
                fu: fu,
                addingFu: addingFu,
                wasRon: false,
                wasTsumo: false,
                selectedLoser: nil
            )
        }

        let winnerPoints: Int
        let regularMinusPoints: Int

        if threePlayerMode {
            winnerPoints = 2000 / tenpaiCount
            if tenpaiCount == 1 {
                regularMinusPoints = winnerPoints / 2
            } else {
                regularMinusPoints = 2000
            }
        } else {
            winnerPoints = 3000 / tenpaiCount
            if tenpaiCount == 1 {
                regularMinusPoints = winnerPoints / 3
            } else if tenpaiCount == 2 {
                regularMinusPoints = winnerPoints
            } else {
                regularMinusPoints = winnerPoints * 3
            }
        }

        for i in updatedPlayers.indices {
            if updatedPlayers[i].tenpai {
                updatedPlayers[i].winner = true
                updatedPlayers[i].tenpai = false
                winningPointsByIndex[i] = winnerPoints
                scoreChangesByIndex[i] = !(threePlayerMode && i == 3)
            } else {
                updatedPlayers[i].loser = true
                losingPointsByIndex[i] = regularMinusPoints
                scoreChangesByIndex[i] = !(threePlayerMode && i == 3)
            }
        }

        return ScoreApplicationPlan(
            players: updatedPlayers,
            winningPointsByIndex: winningPointsByIndex,
            losingPointsByIndex: losingPointsByIndex,
            scoreChangesByIndex: scoreChangesByIndex,
            shouldRotateWinds: shouldRotateWinds,
            honbaCount: nextHonbaCount,
            riichiPot: riichiPot,
            riichiPotIndicator: riichiPot / 1000,
            han: han,
            fu: fu,
            addingFu: addingFu,
            wasRon: false,
            wasTsumo: false,
            selectedLoser: nil
        )
    }
}
