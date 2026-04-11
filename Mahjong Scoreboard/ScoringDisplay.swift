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

    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundColor(.black)
                .opacity(0.8)
            VStack {
                Text(titleText)
                    .font(.system(size: 50))
                    .padding()

                if isMultipleRon {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(multipleRonSummaryLines, id: \.self) { line in
                            Text(line)
                                .font(.largeTitle)
                        }
                    }
                    .font(.title2)
                    .padding(.top, 6)

                    VStack {
                        Text("Total paid:")
                        Text("\(multipleRonTotalPaid)")
                    }
                    .font(.largeTitle)
                    .padding(.top, 8)

                    if multipleRonHonbaIncreases {
                        Text("Honba increases by 1")
                            .font(.title2)
                            .padding(.top, 6)
                    }
                }

                if wasTsumo {
                    if winner == "東" {
                        VStack {
                            Text("Each player pays: ")
                            Text("\(String(format: "%d", nonDealerPayment))")
                        }
                        .font(.largeTitle)
                        .padding()
                        Text(displayedHanFuText)
                        if han == 26 {
                            VStack {
                                Text("Double yakuman base points: 16000")
                                Text("Dealer tsumo payment: 16000 * 2 = 32000")
                                Text("Honba points: \(honbaCount) * 100 = \(honbaCount * 100)")
                                Text("Payout: 32000 + \(honbaCount * 100) = \(String(format: "%d", nonDealerPayment))")
                            }
                        } else if isLimitHand {
                            VStack {
                                Text("\(limitName ?? "Limit hand") base points: \(String(format: "%d", basePoints))")
                                Text("Dealer base point multiplier: 2")
                                Text("\(String(format: "%d", basePoints)) * 2 = \(String(format: "%d", nonDealerPayment))")
                                Text("Honba points: \(honbaCount) * 100 = \(honbaCount * 100)")
                                Text("Payout: \(String(format: "%d", nonDealerPayment - honbaCount * 100)) + \(honbaCount * 100) = \(String(format: "%d", nonDealerPayment))")
                            }
                        } else {
                            HStack(spacing: 2) {
                                Text("Base points = \(String(format: "%d", fu)) fu * 2")
                                Text("2 + \(String(format: "%d", han)) han")
                                    .font(.system(size: 12))
                                    .baselineOffset(8)
                                Text(" = \(String(format: "%d", fu * Int(pow(2.0, Double(2 + han)))))")
                            }
                        }
                    } else {
                        VStack {
                            Text("東 pays:")
                            Text("\(String(format: "%d", dealerPayment))")
                        }
                        .font(.largeTitle)
                        .padding()
                        VStack {
                            if han == 26 {
                                Text("Double yakuman base points: 16000")
                                Text("Dealer tsumo payment: 16000 * 2 = 32000")
                                Text("Honba points: \(String(format: "%d", honbaCount)) * 100 = \(String(format: "%d", honbaCount * 100))")
                                Text("Payout: 32000 + \(String(format: "%d", honbaCount * 100)) = \(String(format: "%d", dealerPayment))")
                            } else if isLimitHand {
                                Text(displayedHanFuText)
                                Text("\(limitName ?? "Limit hand") base points: \(String(format: "%d", basePoints))")
                                Text("Dealer base point multiplier: 2")
                                Text("\(String(format: "%d", basePoints)) * 2 = \(String(format: "%d", dealerPayment))")
                                Text("Honba points: \(String(format: "%d", honbaCount)) * 100 = \(String(format: "%d", honbaCount * 100))")
                                Text("Payout: \(String(format: "%d", dealerPayment - honbaCount * 100)) + \(String(format: "%d", honbaCount * 100)) = \(String(format: "%d", dealerPayment))")
                            } else {
                                Text("Han: \(han), Fu: \(fu)")
                                HStack(spacing: 2) {
                                    Text("Base points = \(String(format: "%d", fu)) fu * 2")
                                    Text("2 + \(String(format: "%d", han)) han")
                                        .font(.system(size: 12))
                                        .baselineOffset(8)
                                    Text(" = \(String(format: "%d", fu * Int(pow(2.0, Double(2 + han)))))")
                                }
                                Text("Dealer base point multiplier: 2")
                                Text("\(String(format: "%d", basePoints)) * 2 = \(String(format: "%d", basePoints * 2))")
                                Text("Rounded up to the nearest hundred: \(String(format: "%d", Int(ceil(Double(basePoints * 2) / 100.0) * 100.0)))")
                                Text("Honba points: \(String(format: "%d", honbaCount)) * 100 = \(String(format: "%d", honbaCount * 100))")
                                Text("Payout: \(String(format: "%d", Int(ceil(Double(basePoints * 2) / 100.0) * 100.0))) + \(String(format: "%d", honbaCount * 100)) = \(String(format: "%d", dealerPayment))")
                            }
                        }
                        VStack {
                            Text("Non-dealers pay:")
                            Text("\(String(format: "%d", nonDealerPayment))")
                        }
                        .font(.largeTitle)
                        .padding()
                    }
                    VStack {
                        if han != 26 {
                            if isLimitHand {
                                if winner == "東" {
                                    // Text("\(limitName ?? "Limit hand") base points: \(String(format: "%d", basePoints))")
                                } else {
                                    Text("\(limitName ?? "Limit hand") base points: \(String(format: "%d", basePoints))")
                                }
                            } else if winner == "東" {
                                Text("Base point multiplier: 2")
                            } else {
                                Text("Non-dealer base point multiplier: 1")
                            }
                            if isLimitHand {
                                if winner == "東" && han != 26 {
                                    // Text("Payout: \(String(format: "%d", nonDealerPayment - honbaCount * 100)) + \(String(format: "%d", honbaCount * 100)) = \(String(format: "%d", nonDealerPayment))")
                                } else {
                                    Text("Non-dealer payout: \(String(format: "%d", nonDealerPayment - honbaCount * 100)) + \(String(format: "%d", honbaCount * 100)) = \(String(format: "%d", nonDealerPayment))")
                                }
                            } else if winner == "東" {
                                
                                Text("\(String(format: "%d", basePoints)) * 2 = \(String(format: "%d", basePoints * 2))")
                                Text("Rounded up to the nearest hundred: \(String(format: "%d", Int(ceil(Double(basePoints * 2) / 100.0) * 100.0)))")
                                Text("Honba points: \(String(format: "%d", honbaCount)) * 100 = \(String(format: "%d", honbaCount * 100))")
                                Text("Payout: \(String(format: "%d", Int(ceil(Double(basePoints * 2) / 100.0) * 100.0))) + \(String(format: "%d", honbaCount * 100)) = \(String(format: "%d", nonDealerPayment))")
                                
                            } else {
                                Text("\(String(format: "%d", basePoints)) * 1 = \(String(format: "%d", basePoints * 1))")
                                Text("Rounded up to the nearest hundred: \(String(format: "%d", Int(ceil(Double(basePoints * 1) / 100.0) * 100.0)))")
                                Text("Non-dealer payout: \(String(format: "%d", Int(ceil(Double(basePoints * 1) / 100.0) * 100.0))) * 1 + \(String(format: "%d", honbaCount * 100)) = \(String(format: "%d", nonDealerPayment))")
                            }
                        }
                    }
                    VStack {
                        Text("Total winnings:")
                        if winner == "東" {
                            Text("\(String(format: "%d", nonDealerPayment * dealerTsumoPayerCount + riichiPot))")
                        } else {
                            Text("\(String(format: "%d", dealerPayment + (nonDealerPayment * nonDealerTsumoPayerCount) + riichiPot))")
                        }
                    }
                    .padding()
                    .font(.largeTitle)
                    VStack {
                        if winner == "東" {
                            Text("Payout: \(String(format: "%d", nonDealerPayment)) * \(dealerTsumoPayerCount) = \(String(format: "%d", nonDealerPayment * dealerTsumoPayerCount))")
                        } else {
                            Text("Payout: \(String(format: "%d", dealerPayment)) + \(String(format: "%d", nonDealerPayment)) * \(nonDealerTsumoPayerCount) = \(String(format: "%d", dealerPayment + nonDealerPayment * nonDealerTsumoPayerCount))")
                        }
                        if riichiPot > 0 {
                            Text("Riichi pot: \(String(format: "%d", riichiPot))")
                            if winner == "東" {
                                Text("\(String(format: "%d", nonDealerPayment * dealerTsumoPayerCount)) + \(String(format: "%d", riichiPot)) = \(String(format: "%d", nonDealerPayment * dealerTsumoPayerCount + riichiPot))")
                            } else {
                                Text("\(String(format: "%d", dealerPayment + nonDealerPayment * nonDealerTsumoPayerCount)) + \(String(format: "%d", riichiPot)) = \(String(format: "%d", dealerPayment + nonDealerPayment * nonDealerTsumoPayerCount + riichiPot))")
                            }
                        }
                        
                    }
                }
                
                if wasRon {
                    VStack {
                        Text("\(loser) pays:")
                        Text("\(String(format: "%d", winnerPoints))")
                    }
                    .font(.largeTitle)
                    .padding()
                    VStack {
                        Text(displayedHanFuText)
                        if han == 26 {
                            Text("Honba points: \(honbaCount) * 300 = \(honbaCount * 300)")
                            Text("Payout: \(String(format: "%d", winnerPoints - honbaCount * 300)) + \(honbaCount * 300) = \(String(format: "%d", winnerPoints))")
                        } else if isLimitHand {
                            Text("\(limitName ?? "Limit hand") base points: \(String(format: "%d", basePoints))")
                            Text("Base point multiplier: \(multiplier) (\(winner == "東" ? "dealer" : "non-dealer"))")
                            Text("\(String(format: "%d", basePoints)) * \(multiplier) = \(String(format: "%d", basePoints * multiplier))")
                            Text("Honba points: \(honbaCount) * 300 = \(honbaCount * 300)")
                            Text("Payout: \(String(format: "%d", winnerPoints - honbaCount * 300)) + \(honbaCount * 300) = \(String(format: "%d", winnerPoints))")
                        } else {
                            HStack(spacing: 2) {
                                Text("Base points = \(fu) fu * 2")
                                Text("2 + \(han) han")
                                    .font(.system(size: 12))
                                    .baselineOffset(8)
                                Text(" = \(String(format: "%d", fu * Int(pow(2.0, Double(2 + han)))))")
                            }
                            Text("Base point multiplier: \(multiplier) (\(winner == "東" ? "dealer" : "non-dealer"))")
                            Text("\(String(format: "%d", basePoints)) * \(multiplier) = \(String(format: "%d", basePoints * multiplier))")
                            Text("Rounded up the nearest hundred or minimum: \(String(format: "%d", winnerPoints - honbaCount * 300))")
                            Text("Honba points: \(honbaCount) * 300 = \(honbaCount * 300)")
                            Text("Payout: \(String(format: "%d", (winnerPoints - honbaCount * 300))) + \(honbaCount * 300) = \(String(format: "%d", winnerPoints))")
                        }
                    }
                    VStack {
                        Text("Total winnings:")
                        Text("\(String(format: "%d", winnerPoints + riichiPot))")
                    }
                    .padding()
                    .font(.largeTitle)
                    VStack {
                        Text("Payout: \(String(format: "%d", winnerPoints))")
                        Text("Riichi pot: \(String(format: "%d", riichiPot))")
                        Text("\(String(format: "%d", winnerPoints)) + \(String(format: "%d", riichiPot)) = \(String(format: "%d", winnerPoints + riichiPot))")
                        
                    }
                }
                
                if winner == "東" {
                    Text("Honba increases by 1")
                        .font(.title2)
                        .padding()
                }
            }
            .foregroundStyle(.white)
            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
        }
    }
}

#Preview {
    ScoringDisplay(winner: "東", wasTsumo: false, wasRon: true, han: 1, fu: 20, honbaCount: 1, basePoints: 160, nonDealerPayment: 800, riichiPot: 1000, dealerPayment: 1300, loser: "西", multiplier: 6, winnerPoints: 1500, threePlayerMode: false, multipleRonTitle: nil, multipleRonSummaryLines: [], multipleRonTotalPaid: 0, multipleRonHonbaIncreases: false, onDismiss: {})
}
