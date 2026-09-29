import Foundation

struct MultipleRonBreakdown {
    let winnerPointsByIndex: [Int]
    let loserIndex: Int
    let loserWind: String
    let orderedWinnerIndices: [Int]
    let summaryLines: [String]
    let winnerTitle: String
    let totalLoss: Int
    let honbaCountWillIncrease: Bool
}

enum MultipleRonScoring {
    static func calculateBreakdown(
        players: [Player],
        selectedLoser: String?,
        honbaCount: Int,
        riichiPot: Int,
        threePlayerMode: Bool = false
    ) -> MultipleRonBreakdown? {
        guard let loserWind = selectedLoser, !loserWind.isEmpty,
              let loserIndex = players.firstIndex(where: { $0.wind == loserWind }) else {
            return nil
        }

        let winnerIndices = players.indices.filter { players[$0].multRonWin }
        if winnerIndices.isEmpty {
            return nil
        }

        var winnerPointsByIndex = Array(repeating: 0, count: players.count)
        var honbaCountWillIncrease = false

        for i in winnerIndices {
            winnerPointsByIndex[i] = HandScoring.calculateRon(
                winnerWind: players[i].wind,
                han: players[i].han,
                fu: players[i].fu,
                honbaCount: honbaCount,
                threePlayerMode: threePlayerMode
            ).winnerPoints

            if players[i].wind == "東" {
                honbaCountWillIncrease = true
            }
        }

        // The riichi pot supplements winnings; it is not paid again by the discarder.
        let paymentsByIndex = winnerPointsByIndex

        if riichiPot > 0 {
            let winnerCount = winnerIndices.count
            let rawShare = riichiPot / winnerCount
            let share = (rawShare / 100) * 100
            let remainder = riichiPot - (share * winnerCount)

            for i in winnerIndices {
                winnerPointsByIndex[i] += share
            }

            if remainder > 0 {
                let clockwiseOrder = (1...3).map { (loserIndex + $0) % players.count }
                if let firstWinnerIndex = clockwiseOrder.first(where: { winnerIndices.contains($0) }) {
                    winnerPointsByIndex[firstWinnerIndex] += remainder
                }
            }
        }

        let clockwiseOrder = (1...3).map { (loserIndex + $0) % players.count }
        let orderedWinnerIndices = clockwiseOrder.filter { winnerIndices.contains($0) }
        let orderedWinnerWinds = orderedWinnerIndices.map { players[$0].wind }
        let totalLoss = orderedWinnerIndices.reduce(0) { $0 + paymentsByIndex[$1] }
        let summaryLines = orderedWinnerIndices.flatMap { i -> [String] in
            var lines = ["\(loserWind) pays \(players[i].wind): \(paymentsByIndex[i])"]
            let potShare = winnerPointsByIndex[i] - paymentsByIndex[i]
            if potShare > 0 {
                lines.append("\(players[i].wind) receives \(potShare) from the riichi pot")
            }
            return lines
        }

        return MultipleRonBreakdown(
            winnerPointsByIndex: winnerPointsByIndex,
            loserIndex: loserIndex,
            loserWind: loserWind,
            orderedWinnerIndices: orderedWinnerIndices,
            summaryLines: summaryLines,
            winnerTitle: makeWinnerTitle(from: orderedWinnerWinds),
            totalLoss: totalLoss,
            honbaCountWillIncrease: honbaCountWillIncrease
        )
    }

    private static func makeWinnerTitle(from winnerWinds: [String]) -> String {
        if winnerWinds.count == 2 {
            return "\(winnerWinds[0])と\(winnerWinds[1])の和了"
        }
        return "\(winnerWinds.joined(separator: "・"))の和了"
    }
}
