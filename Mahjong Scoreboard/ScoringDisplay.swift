//
//  ScoringDisplay.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 8/25/25.
//

import SwiftUI

struct ScoringDisplay: View {
    let winner: String
    let wasTsumo: Bool
    let wasRon: Bool
    let han: Int
    let fu: Int
    let honbaCount: Int
    let basePoints: Int
    let nonDealerPayment: Int
    let riichiPot: Int
    let dealerPayment: Int
    let loser: String
    let multiplier: Int
    let winnerPoints: Int
    let threePlayerMode: Bool
    let bisectNorth: Bool
    let multipleRonTitle: String?
    let multipleRonSummaryLines: [String]
    let multipleRonTotalPaid: Int
    let multipleRonHonbaIncreases: Bool
    let onDismiss: () -> Void

    private var isMultipleRon: Bool {
        multipleRonTitle != nil
    }

    private var titleText: String {
        multipleRonTitle ?? "\(winner)の和了"
    }

    private var dealerTsumoPayerCount: Int {
        threePlayerMode ? 2 : 3
    }

    private var nonDealerTsumoPayerCount: Int {
        threePlayerMode ? 1 : 2
    }

    private var isLimitHand: Bool {
        han >= 5
    }

    private var limitName: String? {
        switch han {
        case 5:
            return "Mangan"
        case 6...7:
            return "Haneman"
        case 8...10:
            return "Baiman"
        case 11...12:
            return "Sanbaiman"
        case 13...25:
            return "Yakuman"
        case 26:
            return "Double yakuman"
        default:
            return nil
        }
    }

    private var displayedHanFuText: String {
        if let limitName {
            return "Han: \(han) (\(limitName))"
        }
        return "Han: \(han), Fu: \(fu)"
    }

    private func tsumoDetails(_ standardScore: TsumoScoreBreakdown) -> some View {
        let scoringBase = han == 26 ? 16000 : standardScore.basePoints
        return VStack(spacing: 6) {
            Text(displayedHanFuText)
            if isLimitHand {
                Text("\(limitName ?? "Limit hand") base points: \(scoringBase)")
            } else {
                let rawBase = fu * Int(pow(2.0, Double(2 + han)))
                Text("Base points = \(fu) fu × 2^(2 + \(han)) = \(rawBase)")
                if rawBase > scoringBase {
                    Text("Base points capped at \(scoringBase) (Mangan)")
                }
            }
            Text("Honba per active opponent: \(honbaCount) × 100 = \(honbaCount * 100)")
            if winner == "東" {
                originalTsumoPaymentDetails(
                    title: "Each active non-dealer",
                    base: scoringBase,
                    multiplier: 2,
                    payment: standardScore.nonDealerPayment
                )
            } else {
                originalTsumoPaymentDetails(
                    title: "Dealer",
                    base: scoringBase,
                    multiplier: 2,
                    payment: standardScore.dealerPayment
                )
                originalTsumoPaymentDetails(
                    title: "Active non-dealer",
                    base: scoringBase,
                    multiplier: 1,
                    payment: standardScore.nonDealerPayment
                )
            }
        }
    }

    private func originalTsumoPaymentDetails(title: String, base: Int, multiplier: Int, payment: Int) -> some View {
        let beforeHonba = payment - honbaCount * 100
        return VStack(spacing: 4) {
            Text(title)
                .fontWeight(.semibold)
            Text("Base point multiplier: \(multiplier)")
            Text("\(base) × \(multiplier) = \(base * multiplier)")
            Text("Rounded up to the nearest 100 or minimum: \(beforeHonba)")
            Text("\(threePlayerMode && bisectNorth ? "Before North bisection" : "Payment"): \(beforeHonba) + \(honbaCount * 100) = \(payment)")
        }
        .padding(.top, 6)
    }

    private var tsumoTotal: Int {
        winner == "東"
            ? nonDealerPayment * dealerTsumoPayerCount
            : dealerPayment + nonDealerPayment * nonDealerTsumoPayerCount
    }

    @ViewBuilder
    private var paymentSummary: some View {
        if wasTsumo {
            if winner == "東" {
                Text("Each player pays: \(nonDealerPayment)")
            } else {
                Text("東 pays: \(dealerPayment)")
                Text("Non-dealer\(nonDealerTsumoPayerCount == 1 ? "" : "s") pay\(nonDealerTsumoPayerCount == 1 ? "s" : ""): \(nonDealerPayment)")
            }
        } else if wasRon {
            Text("\(loser) pays: \(winnerPoints)")
        }
    }

    private var ronDetails: some View {
        let scoringBase = han == 26 ? 16000 : basePoints
        let honbaValue = threePlayerMode ? 200 : 300
        return VStack(spacing: 6) {
            Text(displayedHanFuText)
            if isLimitHand {
                Text("\(limitName ?? "Limit hand") base points: \(scoringBase)")
            } else {
                let rawBase = fu * Int(pow(2.0, Double(2 + han)))
                Text("Base points = \(fu) fu × 2^(2 + \(han)) = \(rawBase)")
                if rawBase > scoringBase {
                    Text("Base points capped at \(scoringBase) (Mangan)")
                }
            }
            Text("Base point multiplier: \(multiplier) (\(winner == "東" ? "dealer" : "non-dealer"))")
            Text("\(scoringBase) × \(multiplier) = \(scoringBase * multiplier)")
            Text("Rounded up to the nearest 100 or minimum: \(winnerPoints - honbaCount * honbaValue)")
            Text("Honba points: \(honbaCount) × \(honbaValue) = \(honbaCount * honbaValue)")
            Text("Payout: \(winnerPoints - honbaCount * honbaValue) + \(honbaCount * honbaValue) = \(winnerPoints)")
            Text("Riichi pot: \(riichiPot)")
            Text("\(winnerPoints) + \(riichiPot) = \(winnerPoints + riichiPot)")
        }
    }

    @ViewBuilder
    private var scoringDetails: some View {
        if isMultipleRon {
            ForEach(multipleRonSummaryLines, id: \.self) { line in
                Text(line)
            }
        } else if wasTsumo {
            let standardScore = HandScoring.calculateTsumo(
                winnerWind: winner,
                han: han,
                fu: fu,
                honbaCount: honbaCount,
                threePlayerMode: false
            )
            tsumoDetails(standardScore)
            if threePlayerMode && bisectNorth {
                let northPayment = standardScore.nonDealerPayment - honbaCount * 100
                let northShare = nonDealerPayment - standardScore.nonDealerPayment
                VStack(spacing: 6) {
                    Text("North's payment (no honba): \(northPayment)")
                    Text("Half of North's payment: \(northPayment) / 2 = \(northPayment / 2)")
                    Text("Rounded up to the next 100: \(northShare)")
                    if winner == "東" {
                        Text("Each player pays: \(standardScore.nonDealerPayment) + \(northShare) = \(nonDealerPayment)")
                    } else {
                        Text("東 pays: \(standardScore.dealerPayment) + \(northShare) = \(dealerPayment)")
                        Text("Non-dealer pays: \(standardScore.nonDealerPayment) + \(northShare) = \(nonDealerPayment)")
                    }
                }
                .padding(.top, 12)
            }
            VStack(spacing: 6) {
                if winner == "東" {
                    Text("Payout: \(nonDealerPayment) × \(dealerTsumoPayerCount) = \(tsumoTotal)")
                } else {
                    Text("Payout: \(dealerPayment) + \(nonDealerPayment) × \(nonDealerTsumoPayerCount) = \(tsumoTotal)")
                }
                Text("Riichi pot: \(riichiPot)")
                Text("\(tsumoTotal) + \(riichiPot) = \(tsumoTotal + riichiPot)")
            }
            .padding(.top, 12)
        } else if wasRon {
            ronDetails
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            VStack(spacing: 12) {
                Text(titleText)
                    .font(.system(size: 50))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                VStack(spacing: 8) {
                    paymentSummary
                }
                .font(.largeTitle)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)

                ScrollView(.vertical) {
                    VStack(spacing: 8) {
                        scoringDetails
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .scrollBounceBehavior(.basedOnSize)
                .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 8) {
                    if isMultipleRon {
                        Text("Total paid: \(multipleRonTotalPaid)")
                    } else if wasTsumo {
                        Text("Total winnings: \(tsumoTotal + riichiPot)")
                    } else if wasRon {
                        Text("Total winnings: \(winnerPoints + riichiPot)")
                    }
                }
                .font(.largeTitle)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)

                if (isMultipleRon && multipleRonHonbaIncreases) || (!isMultipleRon && winner == "東") {
                    Text("Honba increases by 1")
                        .font(.title2)
                }
            }
            .padding()
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .contentShape(Rectangle())
            .onTapGesture {
                onDismiss()
            }
        }
    }
}

#Preview {
    ScoringDisplay(winner: "東", wasTsumo: false, wasRon: true, han: 1, fu: 20, honbaCount: 1, basePoints: 160, nonDealerPayment: 800, riichiPot: 1000, dealerPayment: 1300, loser: "西", multiplier: 6, winnerPoints: 1500, threePlayerMode: false, bisectNorth: false, multipleRonTitle: nil, multipleRonSummaryLines: [], multipleRonTotalPaid: 0, multipleRonHonbaIncreases: false, onDismiss: {})
}
