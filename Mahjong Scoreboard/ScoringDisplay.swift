//
//  ScoringDisplay.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 8/25/25.
//

import SwiftUI

struct ScoringDisplay: View {
    @Binding var winner: String
    @Binding var wasTsumo: Bool
    @Binding var wasRon: Bool
    @Binding var han: Int
    @Binding var fu: Int
    @Binding var honbaCount: Int
    @Binding var basePoints: Int
    @Binding var nonDealerPayment: Int
    @Binding var riichiPot: Int
    @Binding var dealerPayment: Int
    @Binding var loser: String
    @Binding var multiplier: Int
    @Binding var winnerPoints: Int
    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundColor(.black)
                .opacity(0.8)
                .onTapGesture {
                    
                }
            VStack {
                Text("\(winner)の勝ち")
                    .font(.system(size: 50))
                    .padding()
                
                if wasTsumo {
                    if winner == "東" {
                        VStack {
                            Text("Each player pays: ")
                            Text("\(String(format: "%d", nonDealerPayment))")
                        }
                        .font(.largeTitle)
                        .padding()
                    } else {
                        VStack {
                            Text("東 pays:")
                            Text("\(String(format: "%d", dealerPayment))")
                        }
                        .font(.largeTitle)
                        .padding()
                        VStack {
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
                            Text("Honba points: \(String(format: "%d", honbaCount)) * 300 = \(String(format: "%d", honbaCount * 300))")
                            Text("Payout: \(String(format: "%d", Int(ceil(Double(basePoints * 2) / 100.0) * 100.0))) + \(String(format: "%d", honbaCount * 300)) = \(String(format: "%d", dealerPayment))")
                        }
                        VStack {
                            Text("南, 西, 北 pay:")
                            Text("\(String(format: "%d", nonDealerPayment))")
                        }
                        .font(.largeTitle)
                        .padding()
                    }
                    VStack {
                        if winner == "東" {
                            Text("Base point multiplier: 2")
                        } else {
                            Text("Non-dealer base point multiplier: 1")
                        }
                        if winner == "東" {
                            
                            Text("\(String(format: "%d", basePoints)) * 2 = \(String(format: "%d", basePoints * 2))")
                            Text("Rounded up to the nearest hundred: \(String(format: "%d", Int(ceil(Double(basePoints * 2) / 100.0) * 100.0)))")
                            Text("Honba points: \(String(format: "%d", honbaCount)) * 300 = \(String(format: "%d", honbaCount * 300))")
                            Text("Payout: \(String(format: "%d", Int(ceil(Double(basePoints * 2) / 100.0) * 100.0))) + \(String(format: "%d", honbaCount * 300)) = \(String(format: "%d", nonDealerPayment))")
                            
                        } else {
                            Text("\(String(format: "%d", basePoints)) * 1 = \(String(format: "%d", basePoints * 1))")
                            Text("Rounded up to the nearest hundred: \(String(format: "%d", Int(ceil(Double(basePoints * 1) / 100.0) * 100.0)))")
                            Text("Non-dealer payout: \(String(format: "%d", Int(ceil(Double(basePoints * 1) / 100.0) * 100.0))) * 1 + \(String(format: "%d", honbaCount * 300)) = \(String(format: "%d", nonDealerPayment))")
                        }
                    }
                    VStack {
                        Text("Total winnings:")
                        if winner == "東" {
                            Text("\(String(format: "%d", nonDealerPayment * 3 + riichiPot))")
                        } else {
                            Text("\(String(format: "%d", dealerPayment + (nonDealerPayment * 2) + riichiPot))")
                        }
                    }
                    .padding()
                    .font(.largeTitle)
                    VStack {
                        if winner == "東" {
                            Text("Payout: \(String(format: "%d", nonDealerPayment)) * 3 = \(String(format: "%d", nonDealerPayment * 3))")
                        } else {
                            Text("Payout: \(String(format: "%d", dealerPayment)) + \(String(format: "%d", nonDealerPayment)) * 2 = \(String(format: "%d", dealerPayment + nonDealerPayment * 2))")
                        }
                        if riichiPot > 0 {
                            Text("Riichi pot: \(String(format: "%d", riichiPot))")
                            if winner == "東" {
                                Text("\(String(format: "%d", nonDealerPayment * 3)) + \(String(format: "%d", riichiPot)) = \(String(format: "%d", nonDealerPayment * 3 + riichiPot))")
                            } else {
                                Text("\(String(format: "%d", dealerPayment + nonDealerPayment * 2)) + \(String(format: "%d", riichiPot)) = \(String(format: "%d", dealerPayment + nonDealerPayment * 2 + riichiPot))")
                            }
                        }
                        
                    }
                }
                
                if wasRon {
                    VStack {
                        Text("\(loser) pays:")
                        Text("1300")
                    }
                    .font(.largeTitle)
                    .padding()
                    VStack {
                        Text("Han: \(han), Fu: \(fu)")
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
                    VStack {
                        Text("Total winnings:")
                        Text("2300")
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
        }
    }
}

#Preview {
    ScoringDisplay(winner: .constant("東"), wasTsumo: .constant(false), wasRon: .constant(true), han: .constant(1), fu: .constant(20), honbaCount: .constant(1), basePoints: .constant(160), nonDealerPayment: .constant(800), riichiPot: .constant(1000), dealerPayment: .constant(1300), loser: .constant("西"), multiplier: .constant(6), winnerPoints: .constant(1500))
}
