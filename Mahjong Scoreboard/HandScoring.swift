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
        threePlayerMode: Bool,
        bisectNorth: Bool = false
    ) -> TsumoScoreBreakdown {
        if threePlayerMode && bisectNorth {
            let fourPlayerScore = calculateTsumo(
                winnerWind: winnerWind,
                han: han,
                fu: fu,
                honbaCount: honbaCount,
                threePlayerMode: false
            )
            // North contributes no honba; round each half of the hand payment up to 100.
            let northPayment = fourPlayerScore.nonDealerPayment - 100 * honbaCount
            let northPaymentShare = ((northPayment + 199) / 200) * 100
            let nonDealerPayment = fourPlayerScore.nonDealerPayment + northPaymentShare
            let dealerPayment = winnerWind == "東" ? 0 : fourPlayerScore.dealerPayment + northPaymentShare
            return TsumoScoreBreakdown(
                basePoints: fourPlayerScore.basePoints,
                winnerPoints: winnerWind == "東" ? nonDealerPayment * 2 : dealerPayment + nonDealerPayment,
                dealerPayment: dealerPayment,
                nonDealerPayment: nonDealerPayment
            )
        }

        if han == 26 {
            let basePoints = 16000

            if winnerWind == "東" {
                var nonDealerPayment = basePoints * 2
                nonDealerPayment += 100 * honbaCount
                return TsumoScoreBreakdown(
                    basePoints: 0,
                    winnerPoints: threePlayerMode ? (nonDealerPayment * 2) : (nonDealerPayment * 3),
                    dealerPayment: 0,
                    nonDealerPayment: nonDealerPayment
                )
            }

            let dealerPayment = basePoints * 2 + (100 * honbaCount)
            let nonDealerPayment = basePoints + (100 * honbaCount)

            return TsumoScoreBreakdown(
                basePoints: 0,
                winnerPoints: threePlayerMode ? (dealerPayment + nonDealerPayment) : (dealerPayment + nonDealerPayment * 2),
                dealerPayment: dealerPayment,
                nonDealerPayment: nonDealerPayment
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
        honbaCount: Int,
        threePlayerMode: Bool = false
    ) -> RonScoreBreakdown {
        if han == 26 {
            let singleYakumanPoints = 32000
            var winnerPoints = singleYakumanPoints * 2

            if winnerWind == "東" {
                winnerPoints = Int(Double(winnerPoints) * 1.5)
            }

            winnerPoints += (threePlayerMode ? 200 : 300) * honbaCount
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

        winnerPoints += (threePlayerMode ? 200 : 300) * honbaCount

        return RonScoreBreakdown(
            basePoints: basePoints,
            winnerPoints: winnerPoints,
            multiplier: multiplier
        )
    }
}
