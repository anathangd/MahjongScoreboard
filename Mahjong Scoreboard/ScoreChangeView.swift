//
//  ScoreChangeView.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 9/9/25.
//

import SwiftUI
import Combine

struct ScoreChangeView: View {
    @Binding var player: Player
    @Binding var scoreChange: Int
    @Binding var playerScoreChange: Bool
    @Binding var isWinner: Bool
    @Binding var isLoser: Bool
    let sleepDelay: Double
    
    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State private var waitUntil: Date?
    @State private var isAnimating = false
    @State private var didLogDelayRelease = false
    @State private var didLogFirstTick = false
    
    var body: some View {
        Text((isWinner ? "+" : "-") + String(scoreChange))
            .monospacedDigit()
            .frame(width: 150, height: 20)
            .font(.system(size: 20))
            .onAppear {
                waitUntil = Date().addingTimeInterval(max(0, sleepDelay))
                isAnimating = true
                didLogDelayRelease = false
                didLogFirstTick = false
                }
            .onReceive(timer) { _ in
                guard isAnimating else { return }
                if let waitUntil, Date() < waitUntil { return }
                if !didLogDelayRelease {
                    didLogDelayRelease = true
                }
                if !didLogFirstTick {
                    didLogFirstTick = true
                }
                
                // Determine how much to add/subtract this tick
                let change = min(50, scoreChange) // avoid going below 0
                
                if isWinner {
                    player.score += change
                } else {
                    player.score -= change
                }
                
                scoreChange -= change
                
                if scoreChange <= 0 {
                    scoreChange = 0
                    isAnimating = false
                    waitUntil = nil
                    playerScoreChange = false
                    isWinner = false
                    isLoser = false
                }
            }
            .onDisappear {
                isAnimating = false
                waitUntil = nil
            }
    }
}

//#Preview {
//    ScoreChangeView()
//}
