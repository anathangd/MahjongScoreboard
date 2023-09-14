//
//  RichiiButton.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 9/9/23.
//

import SwiftUI

struct RiichiButton: View {
    var player: Player
    @State var riichi: Bool
    var body: some View {
        ZStack {
            if player.riichi {
                ZStack {
                    Rectangle()
                        .frame(width: 300, height: 30)
                        .border(.black, width: 1)
                        .foregroundColor(.white)
                    Circle()
                        .frame(height: 20)
                        .foregroundColor(.red)
                }
            } else {
                Rectangle()
                    .frame(width: 300, height: 30)
                    .border(.black, width: 1)
                    .foregroundColor(.gray)
                    .opacity(0.06)
            }
            
        }
    }
}

struct RichiiButton_Previews: PreviewProvider {
    static var previews: some View {
        RiichiButton(player: Player(name: "player1", score: 25000, wind: "東", winner: false, loser: false, tenpai: false, riichi: false), riichi: false)
    }
}
