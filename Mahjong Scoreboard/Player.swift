//
//  Player.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 9/9/23.
//

import Foundation

struct Player: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var score: Int
    var wind: String
    var winner: Bool
    var loser: Bool
    var tenpai: Bool
    var riichi: Bool
}
