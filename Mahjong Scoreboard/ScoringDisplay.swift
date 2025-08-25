//
//  ScoringDisplay.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 8/25/25.
//

import SwiftUI

struct ScoringDisplay: View {
    @State var tsumo = false
    @State var ron = true
    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundColor(.black)
                .opacity(0.8)
                .onTapGesture {
                    
                }
            VStack {
                Text("東の勝ち")
                    .font(.system(size: 50))
                    .padding()
                
                if tsumo {
                    VStack {
                        Text("Each player pays: ")
                        Text("1300")
                    }
                    .font(.largeTitle)
                    .padding()
                    VStack {
                        Text("Han: 2")
                        Text("Fu: 25")
                        HStack(spacing: 2) {
                            Text("Base points = 25 fu * 2")
                            Text("2 + 2 han")
                                .font(.system(size: 12))
                                .baselineOffset(8)
                            Text(" = 500")
                        }
                        Text("Honba points: 1 * 300 = 300")
                        Text("Base point multiplier: 2")
                        Text("Payout: 500 * 2 + 300 = 1300")
                    }
                    VStack {
                        Text("Total winnings:")
                        Text("4800")
                    }
                    .padding()
                    .font(.largeTitle)
                    VStack {
                        Text("Payout: 1300 * 3 = 3800")
                        Text("Riichi pot: 1000")
                        
                    }
                }
                
                if ron {
                    VStack {
                        
                        Text("西 pays:")
                        Text("1300")
                    }
                    .font(.largeTitle)
                    .padding()
                    VStack {
                        Text("Han: 2")
                        Text("Fu: 25")
                        HStack(spacing: 2) {
                            Text("Base points = 25 fu * 2")
                            Text("2 + 2 han")
                                .font(.system(size: 12))
                                .baselineOffset(8)
                            Text(" = 500")
                        }
                        Text("Honba points: 1 * 300 = 300")
                        Text("Base point multiplier: 6 (dealer)")
                        Text("Payout: 500 * 2 + 300 = 1300")
                    }
                    VStack {
                        Text("Total winnings:")
                        Text("2300")
                    }
                    .padding()
                    .font(.largeTitle)
                    VStack {
                        Text("Payout: 1300")
                        Text("Riichi pot: 1000")
                        
                    }
                }
                Text("Honba increases by 1")
                    .font(.title2)
                    .padding()
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    ScoringDisplay()
}
