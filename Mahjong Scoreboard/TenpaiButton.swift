//
//  TenpaiButton.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 9/9/23.
//

import SwiftUI

struct TenpaiButton: View {
    
    var player: Player
    @State var tenpai: Bool
    var body: some View {
        
        Text("Tenpai")
            .frame(width: 200, height: 50)
            .background(player.tenpai ? Color.blue: Color.gray)
            .foregroundColor(.white)
            .cornerRadius(15)
            .font(.largeTitle)
            
    }
}

struct TenpaiButton_Previews: PreviewProvider {
    static var previews: some View {
        TenpaiButton(player: Player(name: "player1", score: 25000, wind: "東", winner: false, loser: false, tenpai: false, riichi: false), tenpai: false)
    }
}
