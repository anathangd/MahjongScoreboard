import Foundation

struct ScoreApplicationPlan {
    let players: [Player]
    let winningPointsByIndex: [Int]
    let losingPointsByIndex: [Int]
    let scoreChangesByIndex: [Bool]
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

        for i in updatedPlayers.indices {
            updatedPlayers[i].riichi = false
        }

        let nextHonbaCount = tenpaiCount > 0 ? (honbaCount + 1) : 0
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
