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
    
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    @State private var pointsUnchanged = true
    let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    
    var body: some View {
        Text((isWinner ? "+" : "-") + String(scoreChange))
            .monospacedDigit()
            .frame(width: 150, height: 20)
            .onAppear {
                guard !isPreview else { return }
                timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
            }
            .onReceive(timer ?? Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()) { _ in
                if pointsUnchanged {
                    sleep(UInt32(sleepDelay))
                    pointsUnchanged = false
                }
                
                // Determine how much to add/subtract this tick
                let change = min(10, scoreChange) // avoid going below 0
                
                if isWinner {
                    player.score += change
                } else {
                    player.score -= change
                }
                
                scoreChange -= change
                
                if scoreChange <= 0 {
                    scoreChange = 0
                    timer?.upstream.connect().cancel()
                    pointsUnchanged = true
                    playerScoreChange = false
                    isWinner = false
                    isLoser = false
                }
            }
    }
}

//#Preview {
//    ScoreChangeView()
//}
