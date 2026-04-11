import Foundation

struct TsumoScoreBreakdown {
    let basePoints: Int
    let winnerPoints: Int
    let dealerPayment: Int
    let nonDealerPayment: Int
}

struct RonScoreBreakdown {
    let basePoints: Int
    let winnerPoints: Int
    let multiplier: Int
}

enum HandScoring {
    static func calculateBasePoints(fu: Int, han: Int) -> Int {
        var basePoints = fu * Int(pow(2.0, Double(2 + han)))

        if basePoints > 2000 {
            basePoints = 2000
        }

        if han >= 5 {
            switch han {
            case 5: basePoints = 2000
            case 6...7: basePoints = 3000
            case 8...10: basePoints = 4000
            case 11...12: basePoints = 6000
            default: basePoints = 8000
            }
        }

        return basePoints
    }

    static func calculateTsumo(
        winnerWind: String,
        han: Int,
        fu: Int,
        honbaCount: Int,
        threePlayerMode: Bool
    ) -> TsumoScoreBreakdown {
        if han == 26 {
            let baseWinnerPoints = 32000 * 2

            if winnerWind == "東" {
                let winnerPoints = Int(Double(baseWinnerPoints) * 1.5)
                let nonDealerPayment = Int(ceil(Double(winnerPoints / 3) / 100.0) * 100.0)
                return TsumoScoreBreakdown(
                    basePoints: 0,
                    winnerPoints: winnerPoints,
                    dealerPayment: 0,
                    nonDealerPayment: nonDealerPayment
                )
            }

            return TsumoScoreBreakdown(
                basePoints: 0,
                winnerPoints: baseWinnerPoints,
                dealerPayment: baseWinnerPoints / 2,
                nonDealerPayment: baseWinnerPoints / 4
            )
        }

        let basePoints = calculateBasePoints(fu: fu, han: han)

        if winnerWind == "東" {
            var nonDealerPayment = Int(ceil(Double(basePoints * 2) / 100.0) * 100.0)
            if nonDealerPayment < 400 {
                nonDealerPayment = 400
            }
            nonDealerPayment += 100 * honbaCount

            return TsumoScoreBreakdown(
                basePoints: basePoints,
                winnerPoints: threePlayerMode ? (nonDealerPayment * 2) : (nonDealerPayment * 3),
                dealerPayment: 0,
                nonDealerPayment: nonDealerPayment
            )
        }

        var dealerPayment = Int(ceil(Double(basePoints * 2) / 100.0) * 100.0)
        if dealerPayment < 400 {
            dealerPayment = 400
        }
        dealerPayment += 100 * honbaCount

        var nonDealerPayment = Int(ceil(Double(basePoints) / 100.0) * 100.0)
        if nonDealerPayment < 200 {
            nonDealerPayment = 200
        }
        nonDealerPayment += 100 * honbaCount

        return TsumoScoreBreakdown(
            basePoints: basePoints,
            winnerPoints: threePlayerMode ? (dealerPayment + nonDealerPayment) : (dealerPayment + nonDealerPayment * 2),
            dealerPayment: dealerPayment,
            nonDealerPayment: nonDealerPayment
        )
    }

    static func calculateRon(
        winnerWind: String,
        han: Int,
        fu: Int,
        honbaCount: Int
    ) -> RonScoreBreakdown {
        if han == 26 {
            let singleYakumanPoints = 32000
            var winnerPoints = singleYakumanPoints * 2

            if winnerWind == "東" {
                winnerPoints = Int(Double(winnerPoints) * 1.5)
            }

            winnerPoints += 300 * honbaCount
            return RonScoreBreakdown(
                basePoints: 0,
                winnerPoints: winnerPoints,
                multiplier: winnerWind == "東" ? 6 : 4
            )
        }

        let basePoints = calculateBasePoints(fu: fu, han: han)
        let multiplier = (winnerWind == "東") ? 6 : 4
        var winnerPoints = Int(ceil(Double(basePoints * multiplier) / 100.0) * 100.0)

        if winnerWind == "東" {
            if winnerPoints < 1200 { winnerPoints = 1200 }
        } else {
            if winnerPoints < 1000 { winnerPoints = 1000 }
        }

        winnerPoints += 300 * honbaCount

        return RonScoreBreakdown(
            basePoints: basePoints,
            winnerPoints: winnerPoints,
            multiplier: multiplier
        )
    }
}
