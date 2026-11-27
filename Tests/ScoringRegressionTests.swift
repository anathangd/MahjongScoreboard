import Foundation

// Run with swiftc using Player.swift, HandScoring.swift,
// MultipleRonScoring.swift, and ScoreApplication.swift, then run the executable.
@main
struct ScoringRegressionTests {
    static func main() {
        let winds = ["東", "南", "西", "北"]
        let initialPlayers = winds.map {
            Player(name: $0, score: 25000, wind: $0, winner: false,
                   loser: false, tenpai: false, riichi: false)
        }
        var cases = 0
        for threePlayerMode in [false, true] {
            let activeCount = threePlayerMode ? 3 : 4
            var winds = ["", "東", "南", "西", "北"]
            var roundWind = "東"
            var extraRounds = false
            for rotation in 1...(activeCount * 4) {
                let next = WindRotation.advance(winds: winds, roundWind: roundWind,
                                                extraRounds: extraRounds, threePlayerMode: threePlayerMode)
                winds = next.winds
                roundWind = next.roundWind
                extraRounds = next.extraRounds
                let expectedRound = ["東", "南", "西", "北"][(rotation / activeCount) % 4]
                precondition(roundWind == expectedRound)
                precondition(extraRounds == (roundWind == "西" || roundWind == "北"))
                if threePlayerMode { precondition(winds[4] == "北") }
            }
            precondition(winds == ["", "東", "南", "西", "北"])
        }
        let seatPositions: [(Double, Double)] = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        for winnerIndex in seatPositions.indices {
            for loserIndex in seatPositions.indices where winnerIndex != loserIndex {
                let horizontal = seatPositions[loserIndex].0 - seatPositions[winnerIndex].0
                let vertical = seatPositions[loserIndex].1 - seatPositions[winnerIndex].1
                precondition(RonSwipe.loserIndex(winnerIndex: winnerIndex, horizontal: horizontal, vertical: vertical,
                                                threePlayerMode: false) == loserIndex)
                if winnerIndex != 3 {
                    precondition(RonSwipe.loserIndex(winnerIndex: winnerIndex, horizontal: horizontal, vertical: vertical,
                                                    threePlayerMode: true) == (loserIndex == 3 ? nil : loserIndex))
                }
            }
        }
        precondition(RonSwipe.loserIndex(winnerIndex: 0, horizontal: 1, vertical: 0, threePlayerMode: false) == 1)
        precondition(RonSwipe.loserIndex(winnerIndex: 0, horizontal: -1, vertical: 0, threePlayerMode: false) == 3)
        precondition(RonSwipe.loserIndex(winnerIndex: 1, horizontal: 0, vertical: -1, threePlayerMode: false) == 2)
        precondition(RonSwipe.loserIndex(winnerIndex: 1, horizontal: 0, vertical: 1, threePlayerMode: false) == 0)
        precondition(RonSwipe.loserIndex(winnerIndex: 2, horizontal: -1, vertical: 0, threePlayerMode: false) == 3)
        precondition(RonSwipe.loserIndex(winnerIndex: 2, horizontal: 1, vertical: 0, threePlayerMode: false) == 1)
        precondition(RonSwipe.loserIndex(winnerIndex: 3, horizontal: 0, vertical: -1, threePlayerMode: false) == 2)
        precondition(RonSwipe.loserIndex(winnerIndex: 3, horizontal: 0, vertical: 1, threePlayerMode: false) == 0)
        precondition(RonSwipe.loserIndex(winnerIndex: 0, horizontal: -1, vertical: 0, threePlayerMode: true) == nil)
        precondition(RonSwipe.loserIndex(winnerIndex: 0, horizontal: 0, vertical: 1, threePlayerMode: false) == nil)
        precondition(RonSwipe.loserIndex(winnerIndex: 0, horizontal: 0, vertical: 0, threePlayerMode: false) == nil)
        var historyPlayers = initialPlayers
        historyPlayers[1].riichi = true
        historyPlayers[1].score -= 1000
        historyPlayers[2].winner = true
        let historyPlan = ScoreApplication.ron(players: historyPlayers, winnerPoints: 5200, riichiPot: 2000,
                               winnerWind: "西", loserWind: "南", honbaCount: 1)
        precondition(historyPlan.shouldRotateWinds)
        let history = RoundHistoryEntry(players: historyPlayers, winds: ["", "東", "南", "西", "北"],
                        roundWind: "南", extraRounds: false, honbaCount: 1, riichiPot: 2000,
                        threePlayerMode: false,
                        result: .ron(winner: "西", loser: "南", han: 3, fu: 40, points: 5200),
                        plan: historyPlan)
        precondition(history.round == "South 1 - 1 honba")
        precondition(history.summary(currentPlayers: historyPlayers) == ["西 (西) ron 南 (南) / 3 han/40 fu / 5,200"])
        precondition(history.riichiPlayers(currentPlayers: historyPlayers) == ["南 (南)"])
        precondition(history.playersBeforeRound[1].score == 25000 && !history.playersBeforeRound[1].riichi)
        precondition(history.riichiPotBeforeRound == 1000 && history.honbaCount == 1)
        precondition(history.changes(currentPlayers: historyPlayers).contains("西 (西): +7,200") && history.changes(currentPlayers: historyPlayers).contains("南 (南): −5,200"))
        var renamedPlayers = historyPlayers
        renamedPlayers[1].name = "Renamed"
        precondition(history.summary(currentPlayers: renamedPlayers) == ["西 (西) ron Renamed (南) / 3 han/40 fu / 5,200"])
        precondition(history.riichiPlayers(currentPlayers: renamedPlayers) == ["Renamed (南)"])
        precondition(history.changes(currentPlayers: renamedPlayers).contains("Renamed (南): −5,200"))
        precondition(history.playersBeforeRound(currentPlayers: renamedPlayers)[1].name == "Renamed")
        renamedPlayers[2].name = "Renamed"
        precondition(history.summary(currentPlayers: renamedPlayers) == ["Renamed (西) ron Renamed (南) / 3 han/40 fu / 5,200"])
        renamedPlayers[1].name = "Another name"
        renamedPlayers[1].wind = "北"
        precondition(history.summary(currentPlayers: renamedPlayers) == ["Renamed (西) ron Another name (南) / 3 han/40 fu / 5,200"])
        var tsumoPlayers = initialPlayers
        tsumoPlayers[1].winner = true
        let tsumoPlan = ScoreApplication.tsumo(players: tsumoPlayers, winnerPoints: 1500, dealerPayment: 700,
                               nonDealerPayment: 800, riichiPot: 0, honbaCount: 0,
                               threePlayerMode: true)
        precondition(tsumoPlan.shouldRotateWinds)
        let tsumoHistory = RoundHistoryEntry(players: tsumoPlayers, winds: ["", "東", "南", "西", "北"],
                             roundWind: "東", extraRounds: false, honbaCount: 0, riichiPot: 0,
                             threePlayerMode: true,
                             result: .tsumo(winner: "南", han: 2, fu: 30, points: 1500), plan: tsumoPlan)
                    precondition(tsumoHistory.round == "East 1")
        precondition(tsumoHistory.summary(currentPlayers: tsumoPlayers) == ["南 (南) tsumo / 2 han/30 fu / 1,500"])
        precondition(tsumoHistory.changes(currentPlayers: tsumoPlayers).count == 3 && !tsumoHistory.changes(currentPlayers: tsumoPlayers).contains(where: { $0.contains("北") }))
        var multiplePlayers = initialPlayers
        multiplePlayers[0].multRonWin = true
        multiplePlayers[1].multRonWin = true
        multiplePlayers[0].fu = 30
        multiplePlayers[1].fu = 30
        let multipleBreakdown = MultipleRonScoring.calculateBreakdown(players: multiplePlayers, selectedLoser: "西",
                                           honbaCount: 0, riichiPot: 1000)!
        let multiplePlan = ScoreApplication.multipleRon(players: multiplePlayers, breakdown: multipleBreakdown, honbaCount: 0)
        precondition(!multiplePlan.shouldRotateWinds)
        let multipleHistory = RoundHistoryEntry(players: multiplePlayers, winds: ["", "東", "南", "西", "北"],
                            roundWind: "東", extraRounds: false, honbaCount: 0, riichiPot: 1000,
                            threePlayerMode: false,
                            result: .multipleRon(multipleBreakdown, honbaCount: 0, threePlayerMode: false),
                            plan: multiplePlan)
        precondition(multipleHistory.summary(currentPlayers: multiplePlayers).count == 2 && multipleHistory.summary(currentPlayers: multiplePlayers).allSatisfy { $0.contains("ron 西 (西)") })
        precondition(multipleHistory.changes(currentPlayers: multiplePlayers).count == 3 && multipleHistory.riichiPotBeforeRound == 1000)
        multiplePlayers[0].name = "Winner"
        multiplePlayers[2].name = "Discarder"
        precondition(multipleHistory.summary(currentPlayers: multiplePlayers).contains(where: { $0.contains("Winner (東) ron Discarder (西)") }))
        precondition(multipleHistory.summary(currentPlayers: multiplePlayers).allSatisfy { $0.contains("ron Discarder (西)") })
        let drawPlan = ScoreApplication.exhaustiveDraw(players: initialPlayers, tenpaiCount: 0, honbaCount: 2,
                                   riichiPot: 1000, threePlayerMode: false, han: 1, fu: 20, addingFu: 20)
        precondition(drawPlan.shouldRotateWinds && drawPlan.scoreChangesByIndex.allSatisfy { !$0 })
        let drawHistory = RoundHistoryEntry(players: initialPlayers, winds: ["", "東", "南", "西", "北"],
                            roundWind: "西", extraRounds: true, honbaCount: 2, riichiPot: 1000,
                            threePlayerMode: false, result: .exhaustiveDraw, plan: drawPlan)
        precondition(drawHistory.summary(currentPlayers: initialPlayers) == ["Exhaustive draw"] && drawHistory.changes(currentPlayers: initialPlayers).isEmpty)
        precondition(drawHistory.round == "West 1 - 2 honba" && drawHistory.extraRounds && drawHistory.honbaCount == 2)
        var dealerWinner = initialPlayers
        dealerWinner[0].winner = true
        precondition(!ScoreApplication.ron(players: dealerWinner, winnerPoints: 1500, riichiPot: 0,
                                           winnerWind: "東", loserWind: "南", honbaCount: 0).shouldRotateWinds)
        precondition(!ScoreApplication.tsumo(players: dealerWinner, winnerPoints: 1500, dealerPayment: 0,
                                             nonDealerPayment: 500, riichiPot: 0, honbaCount: 0,
                                             threePlayerMode: false).shouldRotateWinds)
        var nonDealerWinners = initialPlayers
        nonDealerWinners[1].multRonWin = true
        nonDealerWinners[2].multRonWin = true
        let nonDealerBreakdown = MultipleRonScoring.calculateBreakdown(players: nonDealerWinners, selectedLoser: "北",
                                                                       honbaCount: 0, riichiPot: 0)!
        precondition(ScoreApplication.multipleRon(players: nonDealerWinners, breakdown: nonDealerBreakdown,
                                                  honbaCount: 0).shouldRotateWinds)
        for threePlayerMode in [false, true] {
            var nonDealerTenpai = initialPlayers
            nonDealerTenpai[1].tenpai = true
            let plan = ScoreApplication.exhaustiveDraw(players: nonDealerTenpai, tenpaiCount: 1, honbaCount: 0,
                                                       riichiPot: 0, threePlayerMode: threePlayerMode,
                                                       han: 1, fu: 20, addingFu: 20)
            precondition(plan.shouldRotateWinds)
        }
        for winnerCount in [2, 3] {
            for pot in [0, 1000, 2000, 5000] {
                for honba in [0, 1, 3] {
                    for dealerHan in [1, 5, 26] {
                        var players = initialPlayers
                        for i in 0..<winnerCount {
                            players[i].multRonWin = true
                            players[i].fu = 30
                        }
                        players[0].han = dealerHan
                        let result = MultipleRonScoring.calculateBreakdown(
                            players: players, selectedLoser: "北", honbaCount: honba, riichiPot: pot
                        )!
                        let expectedDealer = (dealerHan == 26 ? 96000 : dealerHan == 5 ? 12000 : 1500) + 300 * honba
                        let expectedLoss = expectedDealer + (winnerCount - 1) * (1000 + 300 * honba)
                        precondition(result.totalLoss == expectedLoss, "Discarder must not pay the pot")
                        precondition(result.winnerPointsByIndex.reduce(0, +) == expectedLoss + pot)
                        let share = (pot / winnerCount / 100) * 100
                        let remainder = pot - share * winnerCount
                        precondition(result.winnerPointsByIndex[0] == expectedDealer + share + remainder)
                        precondition(result.summaryLines.contains("北 pays 東: \(expectedDealer)"))
                        let plan = ScoreApplication.multipleRon(players: players, breakdown: result, honbaCount: honba)
                        precondition(plan.losingPointsByIndex[3] == expectedLoss)
                        precondition(plan.winningPointsByIndex.reduce(0, +) - plan.losingPointsByIndex.reduce(0, +) == pot)
                        precondition(plan.riichiPot == 0 && plan.honbaCount == honba + 1)
                        precondition(!plan.shouldRotateWinds)
                        cases += 1
                    }
                }
            }
        }
        for activeCount in [3, 4] {
            for tenpaiCount in 0...activeCount {
                var players = initialPlayers
                for i in 0..<tenpaiCount { players[i].tenpai = true }
                let plan = ScoreApplication.exhaustiveDraw(
                    players: players, tenpaiCount: tenpaiCount, honbaCount: 2,
                    riichiPot: 2000, threePlayerMode: activeCount == 3,
                    han: 1, fu: 20, addingFu: 20
                )
                precondition(plan.players.allSatisfy { !$0.tenpai && !$0.riichi })
                precondition(plan.riichiPot == 2000)
                precondition(plan.honbaCount == 3)
                precondition(plan.shouldRotateWinds == (tenpaiCount == 0))
                let gains = plan.winningPointsByIndex.prefix(activeCount).reduce(0, +)
                let losses = plan.losingPointsByIndex.prefix(activeCount).reduce(0, +)
                precondition(gains == losses)
                if tenpaiCount == 0 || tenpaiCount == activeCount {
                    precondition(gains == 0 && plan.scoreChangesByIndex.allSatisfy { !$0 })
                }
                cases += 1
            }
        }
        print("Passed \(cases) scoring regression cases")
    }
}
