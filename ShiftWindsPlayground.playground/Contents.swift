import UIKit

var windsDictionary = [
    "East": 1,
    "South": 2,
    "West": 3,
    "North": 4
]

for (value, _) in windsDictionary {
    windsDictionary[value]! += 1
    if windsDictionary[value]! > 4 {
        windsDictionary[value] = 1
    }
    if windsDictionary[value] == 1 {
        
    }
}

print(windsDictionary)
//print(windsDictionary["East"] ?? "bleh")

var windsList = [
    "East",
    "South",
    "West",
    "North"
]

var player1Wind = windsList[0]
var player2Wind = windsList[1]
var player3Wind = windsList[2]
var player4Wind = windsList[3]


var popped = windsList.popLast()
windsList.insert(popped ?? "East", at: 0)
print(windsList)

for wind in windsList {
    print(wind)
}


struct Player: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var score: Int
    var wind: String
    var winner: Bool
    var loser: Bool
    var tenpai: Bool
}

var playerList = [
    Player(name: "player1", score: 25000, wind: "東", winner: true, loser: false, tenpai: false),
    Player(name: "player2", score: 25000, wind: "南", winner: false, loser: true, tenpai: false),
    Player(name: "player3", score: 25000, wind: "西", winner: false, loser: false, tenpai: false),
    Player(name: "player4", score: 25000, wind: "北", winner: false, loser: false, tenpai: false)
]


for var player in playerList {
    if player.winner {
        player.score += 1000
        print(player.score)
    }
}
