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

enum WindRotation {
    static func advance(winds: [String], roundWind: String, extraRounds: Bool,
                        threePlayerMode: Bool) -> (winds: [String], roundWind: String, extraRounds: Bool) {
        var nextWinds = winds
        let lastActiveWind = nextWinds.remove(at: threePlayerMode ? 3 : 4)
        nextWinds.insert(lastActiveWind, at: 1)
        var nextRoundWind = roundWind
        var nextExtraRounds = extraRounds
        if nextWinds[1] == "東" {
            switch roundWind {
            case "東": nextRoundWind = "南"
            case "南":
                nextExtraRounds = true
                nextRoundWind = "西"
            case "西": nextRoundWind = "北"
            default:
                nextExtraRounds = false
                nextRoundWind = "東"
            }
        }
        return (nextWinds, nextRoundWind, nextExtraRounds)
    }
}
