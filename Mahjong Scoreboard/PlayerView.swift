//
//  PlayerView.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 4/10/26.
//

import SwiftUI

/// A reusable player tile showing riichi bar, wind button, score, and kanji row.
/// - `isVertical`: true for left/right players (wind sits beside score in an HStack).
///   false for top/bottom players (wind sits above score in a VStack).
/// - `playerDisabled`: true for the left player in 3-player mode (hidden riichi, disabled menu).
/// - Apply `.rotationEffect(.degrees(180))` externally for the top player.
/// - Apply `.frame(300,60).rotationEffect(±90).frame(60,300).padding(40)` externally for side players.
struct PlayerView: View {
    @Binding var player: Player
    let isVertical: Bool
    let timerOn: Bool
    let scoresAreChanging: Bool
    let playerDisabled: Bool
    let menuActionsReversed: Bool
    @Binding var showKanji: Bool
    @Binding var winningPoints: Int
    @Binding var losingPoints: Int
    @Binding var scoreChangeActive: Bool
    let loserWind: String
    let sleepDelay: Double
    let onRon: () -> Void
    let onTsumo: () -> Void
    let onMultipleRon: () -> Void
    let onToggleRiichi: () -> Void
    
    private var bottomRowPadding: CGFloat {
        isVertical ? -15 : -5
    }

    var body: some View {
        VStack(spacing: isVertical ? 10 : 0) {
            RiichiButton(player: player, riichi: player.riichi)
                .onTapGesture { onToggleRiichi() }
                .disabled(playerDisabled)
                .opacity(playerDisabled ? 0 : 1)

            if isVertical {
                HStack {
                    windButton
                    if !playerDisabled {
                        scoreText
                    }
                }
            } else {
                windButton
                scoreText
            }

            ZStack {
                if scoreChangeActive {
                    if player.winner {
                        ScoreChangeView(
                            player: $player,
                            scoreChange: $winningPoints,
                            playerScoreChange: $scoreChangeActive,
                            isWinner: $player.winner,
                            isLoser: $player.loser,
                            sleepDelay: sleepDelay
                        )
                    } else if player.loser || player.wind == loserWind {
                        ScoreChangeView(
                            player: $player,
                            scoreChange: $losingPoints,
                            playerScoreChange: $scoreChangeActive,
                            isWinner: $player.winner,
                            isLoser: $player.loser,
                            sleepDelay: sleepDelay
                        )
                    }
                } else {
                    Text("一 二 三 四 伍 六 七 八 九")
                        .font(.system(size: 20))
                        .opacity(showKanji ? 1 : 0)
                }
            }
            .frame(height: 20)
            .padding(.vertical, bottomRowPadding)
        }
        .font(.system(size: 50))
    }

    private var windButton: some View {
        GlassEffectContainer {
            Menu {
                if menuActionsReversed {
                    Button("Multiple Ron") { onMultipleRon() }
                    Button("Tsumo") { onTsumo() }
                    Button("Ron") { onRon() }
                } else {
                    Button("Ron") { onRon() }
                    Button("Tsumo") { onTsumo() }
                    Button("Multiple Ron") { onMultipleRon() }
                }
            } label: {
                Text(player.wind)
                    .glassEffect(.identity)
            }
            .foregroundStyle(playerDisabled ? .black : .blue)
            .disabled(playerDisabled || timerOn || scoresAreChanging)
        }
    }

    private var scoreText: some View {
        Text(String(player.score))
            .monospacedDigit()
            .onTapGesture { showKanji.toggle() }
    }
}

#Preview {
    @Previewable @State var player = Player(name: "player1", score: 25000, wind: "東", winner: false, loser: false, tenpai: false, riichi: false)
    @Previewable @State var showKanji = false
    PlayerView(
        player: $player,
        isVertical: false,
        timerOn: false,
        scoresAreChanging: false,
        playerDisabled: false,
        menuActionsReversed: false,
        showKanji: $showKanji,
        winningPoints: .constant(0),
        losingPoints: .constant(0),
        scoreChangeActive: .constant(false),
        loserWind: "",
        sleepDelay: 0,
        onRon: {},
        onTsumo: {},
        onMultipleRon: {},
        onToggleRiichi: {}
    )
}
