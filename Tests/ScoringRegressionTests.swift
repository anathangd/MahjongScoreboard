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
                precondition(plan.honbaCount == (tenpaiCount > 0 ? 3 : 0))
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
