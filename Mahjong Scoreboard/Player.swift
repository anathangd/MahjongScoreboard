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
    
    var han: Int = 1
    var fu: Int = 20
    var multRonWin = false
}

enum RonSwipe {
    static func loserIndex(winnerIndex: Int, horizontal: Double, vertical: Double, threePlayerMode: Bool) -> Int? {
        let positions: [(horizontal: Double, vertical: Double)] = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        guard positions.indices.contains(winnerIndex), !(threePlayerMode && winnerIndex == 3) else { return nil }
        let distance = hypot(horizontal, vertical)
        guard distance > 0 else { return nil }
        let winner = positions[winnerIndex]
        var bestIndex: Int?
        var bestAlignment = 0.70
        for index in positions.indices where index != winnerIndex {
            let targetHorizontal = positions[index].horizontal - winner.horizontal
            let targetVertical = positions[index].vertical - winner.vertical
            let targetDistance = hypot(targetHorizontal, targetVertical)
            let alignment = (horizontal * targetHorizontal + vertical * targetVertical) / (distance * targetDistance)
            if alignment > bestAlignment {
                bestAlignment = alignment
                bestIndex = index
            }
        }
        guard let bestIndex, !(threePlayerMode && bestIndex == 3) else { return nil }
        return bestIndex
    }
}
