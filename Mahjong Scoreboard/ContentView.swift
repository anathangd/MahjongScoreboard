//
//  ContentView.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 9/8/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var player1 = Player(name: "player1", score: 25000, wind: "東", winner: false, loser: false, tenpai: false, riichi: false)
    @State var player2 = Player(name: "player2", score: 25000, wind: "南", winner: false, loser: false, tenpai: false, riichi: false)
    @State var player3 = Player(name: "player3", score: 25000, wind: "西", winner: false, loser: false, tenpai: false, riichi: false)
    @State var player4 = Player(name: "player4", score: 25000, wind: "北", winner: false, loser: false, tenpai: false, riichi: false)
    @State var playerList = [
        Player(name: "player1", score: 25000, wind: "東", winner: false, loser: false, tenpai: false, riichi: false),
        Player(name: "player2", score: 25000, wind: "南", winner: false, loser: false, tenpai: false, riichi: false),
        Player(name: "player3", score: 25000, wind: "西", winner: false, loser: false, tenpai: false, riichi: false),
        Player(name: "player4", score: 25000, wind: "北", winner: false, loser: false, tenpai: false, riichi: false)
    ]
    @State var winnerPoints = 0
    @State var dealerMinusPoints = 0
    @State var regularMinusPoints = 0
    @State var riichiPot = 0
    
    @State var winner = "東"
    @State var loser = "南"
    @State var han = 1
    
    @State var windsList = ["東", "南", "西", "北"]
    
    @State var ron = false      //for displaying the ron picker
    @State var tsumo = false    //for displaying the tsumo picker
    @State var exhaust = false  //for displaying the exhaust picker

    @State var tenpaiCounter = 0
    
    var body: some View {
        ZStack {
            
            VStack {
                Menu {
                    Button("Reset") {
                        restart()
                    }
                    
                    Button("Cancel", role: .destructive) {
                        
                    }
                } label: {
                    Image("restarticon").padding().foregroundColor(.blue)
                }
                Button {
                    rotateWinds()
                } label: {
                    Image(systemName: "rotate.left").padding(.top, -20).foregroundColor(.black)
                }
                Button {
                    exhaust = true
                } label: {
                    Image(systemName: "x.circle").foregroundColor(.black)
                        .padding()
                }

                
            }   //menu buttons
            .font(.system(size: 50))
            
            VStack {
                Text(String(playerList[2].score)).rotationEffect(Angle(degrees: 180))
                Menu {
                    Button("Ron") {
                        ron = true
                        playerList[2].winner = true
                        winner = playerList[2].wind
                    }
                    Button("Tsumo") {
                        tsumo = true
                        playerList[2].winner = true
                        winner = playerList[2].wind
                    }
                    Button("Cancel", role: .destructive) {
                        
                    }
                } label: {
                    Text(playerList[2].wind).rotationEffect(Angle(degrees: 180))
                }
                .padding(.top, -30)
                RiichiButton(player: playerList[2], riichi: playerList[2].riichi)
                    .onTapGesture {
                        if playerList[2].riichi {
                            //do nothing
                        } else {
                            playerList[2].riichi = true
                            playerList[2].tenpai = true
                            playerList[2].score -= 1000
                            riichiPot += 1000
                        }
                        
                    }
                Spacer()
                RiichiButton(player: playerList[0], riichi: playerList[0].riichi)
                    .onTapGesture {
                        if playerList[0].riichi {
                            
                        } else {
                            playerList[0].riichi = true
                            playerList[0].tenpai = true
                            playerList[0].score -= 1000
                            riichiPot += 1000
                        }
                    }
                Menu {
                    Button("Cancel", role: .destructive) {
                        
                    }
                    Button("Tsumo") {
                        tsumo = true
                        playerList[0].winner = true
                        winner = playerList[0].wind
                    }
                    Button("Ron") {
                        ron = true
                        playerList[0].winner = true
                        winner = playerList[0].wind
                    }
                } label: {
                    Text(playerList[0].wind)
                }
                .padding(.bottom, -20)
                Text(String(playerList[0].score))
            }   //top and bottom players
            .font(.system(size: 50))
            
            LazyHStack {
                LazyHStack {
                    Menu {
                        Button("Ron") {
                            ron = true
                            playerList[3].winner = true
                            winner = playerList[3].wind
                        }
                        Button("Tsumo") {
                            tsumo = true
                            playerList[3].winner = true
                            winner = playerList[3].wind
                        }
                        Button("Cancel", role: .destructive) {
                            
                        }
                    } label: {
                        Text(playerList[3].wind)
                    }
                    Text(String(playerList[3].score))
                    
                }
                .padding(.bottom, -80)
                .rotationEffect(Angle(degrees: 90))
                
                Spacer()
                LazyHStack {
                    Menu {
                        Button("Cancel", role: .destructive) {
                            
                        }
                        Button("Tsumo") {
                            tsumo = true
                            playerList[1].winner = true
                            winner = playerList[1].wind
                        }
                        Button("Ron") {
                            ron = true
                            playerList[1].winner = true
                            winner = playerList[1].wind
                        }
                    } label: {
                        Text(playerList[1].wind)
                    }
                    Text(String(playerList[1].score))
                }
                .padding(.bottom, -80)
                .rotationEffect(Angle(degrees: -90))
            }   //left and right players
            .font(.system(size: 50))
            
            HStack {
                RiichiButton(player: playerList[3], riichi: playerList[3].riichi)
                    .onTapGesture {
                        if playerList[3].riichi {
                            
                        } else {
                            playerList[3].riichi = true
                            playerList[3].tenpai = true
                            playerList[3].score -= 1000
                            riichiPot += 1000
                        }
                    }.rotationEffect(Angle(degrees: 90))
                    .padding(.trailing, -130)
                RiichiButton(player: playerList[1], riichi: playerList[1].riichi)
                    .onTapGesture {
                        if playerList[1].riichi {
                            
                        } else {
                            playerList[1].riichi = true
                            playerList[1].tenpai = true
                            playerList[1].score -= 1000
                            riichiPot += 1000
                        }
                    }.rotationEffect(Angle(degrees: 90))
            }   //left and right riichi
            
            if ron {
                ZStack {
                    
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.6)
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(width: 420, height: 250)
                            .cornerRadius(15)
                        HStack (spacing: -10){

                            VStack {
                                Text("Loser:")
                                Picker("", selection: $loser) {
                                    ForEach(self.windsList, id: \.self){wind in
                                        Text(wind).font(.system(size: 24))
                                    }
                                }
                                .padding(.top, -20)
                                .pickerStyle(.wheel)
                            }
                            VStack {
                                Text("Han:")
                                Picker("", selection: $han) {
                                    ForEach(1...13, id: \.self) {
                                        Text("\($0)")
                                    }
                                }
                                .padding(.top, -20)
                                .pickerStyle(.wheel)
                            }
                            
                        }
                    }
                    VStack {
                        Spacer()
                        Spacer()
                        Button {
                            scoreRon()
                        } label: {
                            Text("submit")
                                .frame(width: 100, height: 50)
                                .background(.white)
                                .padding(.top, 55)
                                .cornerRadius(15)
                            
                        }
                        .padding(.top, -45)
                        Spacer()
                    }
                    
                }.ignoresSafeArea()
            }
            
            if tsumo {
                ZStack {
                    
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.6)
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(width: 420, height: 250)
                            .cornerRadius(15)
                        HStack {
                            
                            VStack {
                                Text("Han:")
                                Picker("", selection: $han) {
                                    ForEach(1...13, id: \.self) {
                                        Text("\($0)")
                                    }
                                }
                                .padding(.top, -20)
                                .pickerStyle(.wheel)
                            }
                            
                        }
                    }
                    VStack {
                        Spacer()
                        Spacer()
                        Button {
                            tsumo = false
                            scoreTsumo()
                        } label: {
                            Text("submit")
                                .frame(width: 100, height: 50)
                                .background(.white)
                                .padding(.top, 55)
                                .cornerRadius(15)
                                .padding(.top, -45)
                            
                        }
                        Spacer()
                    }
                    
                }
                .ignoresSafeArea()
            }
            
            if exhaust {
                ZStack {
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.6)
                    VStack {
                        TenpaiButton(player: playerList[2], tenpai: playerList[2].tenpai)
                            .rotationEffect(Angle(degrees: 180))
                            .onTapGesture {
                            playerList[2].tenpai.toggle()
                        }
                        Spacer()
                        TenpaiButton(player: playerList[0], tenpai: playerList[0].tenpai)
                            .onTapGesture {
                            playerList[0].tenpai.toggle()
                        }
                    }
                    .padding(50)
                    HStack {
                        TenpaiButton(player: playerList[3], tenpai: playerList[3].tenpai)
                            .rotationEffect(Angle(degrees: 90))
                            .onTapGesture {
                            playerList[3].tenpai.toggle()
                        }
                        Spacer()
                        TenpaiButton(player: playerList[1], tenpai: playerList[1].tenpai)
                            .rotationEffect(Angle(degrees: -90))
                            .onTapGesture {
                            playerList[1].tenpai.toggle()
                        }
                    }
                    .padding(.horizontal, -20)
                    VStack {
                        Spacer()
                        Spacer()
                        Button("done") {
                            exhaust = false
                            scoreExhaust()
                        }.font(.system(size: 30))
                        Spacer()
                    }
                }.ignoresSafeArea()
            }
            
        }.onAppear(perform: {restart()})
    }
        func scoreTsumo() {
            
            switch han {
            case 1: winnerPoints = 1000
            case 2: winnerPoints = 2000
            case 3: winnerPoints = 4000
            case 4, 5: winnerPoints = 8000
            case 6, 7: winnerPoints = 12000
            case 8, 9, 10: winnerPoints = 16000
            case 11, 12: winnerPoints = 24000
            case 13: winnerPoints = 32000
            default: winnerPoints = 0
            }
            
            tsumo = false
            
            if winner == "東" {
                winnerPoints = winnerPoints + winnerPoints / 2
                regularMinusPoints = winnerPoints / 3
            } else {
                dealerMinusPoints = winnerPoints / 2
                regularMinusPoints = dealerMinusPoints / 2
            }
            
            for i in playerList.indices {
                //handle winner
                if playerList[i].winner {
                    playerList[i].score += winnerPoints
                    playerList[i].score += riichiPot
                    riichiPot = 0
                } else {
                    //handle the losers
                    if playerList[i].wind == "東"{
                        playerList[i].score -= dealerMinusPoints
                    } else {
                        playerList[i].score -= regularMinusPoints
                    }
                }
               
                playerList[i].winner = false
                playerList[i].riichi = false
            }
            
            
        }
        
        func scoreRon() {
            
            switch han {
            case 1: winnerPoints = 1000
            case 2: winnerPoints = 2000
            case 3: winnerPoints = 4000
            case 4, 5: winnerPoints = 8000
            case 6, 7: winnerPoints = 12000
            case 8, 9, 10: winnerPoints = 16000
            case 11, 12: winnerPoints = 24000
            case 13: winnerPoints = 32000
            default: winnerPoints = 0
            }
            
            ron = false
            
            for i in playerList.indices {
                if playerList[i].winner {
                    if playerList[i].wind == "東" {
                        winnerPoints = winnerPoints + winnerPoints / 2
                    }
                    playerList[i].score += winnerPoints
                    playerList[i].score += riichiPot
                    riichiPot = 0
                    }
                if playerList[i].wind == loser {
                    playerList[i].score -= winnerPoints
                }
                playerList[i].winner = false
                playerList[i].riichi = false
            }
        }
        
        func scoreExhaust() {
            
            for i in playerList.indices {
                if playerList[i].tenpai {
                    tenpaiCounter += 1
                }
                playerList[i].riichi = false    //pot stays the same
            }
            if (tenpaiCounter == 0 || tenpaiCounter == 4) {
                tenpaiCounter = 1   //just paranoid about dividing by 0
                winnerPoints = 0
            } else {
                winnerPoints = 3000 / tenpaiCounter
                if tenpaiCounter == 1 {
                    regularMinusPoints = winnerPoints / 3   //each player pays 1000
                } else if tenpaiCounter == 2 {
                    regularMinusPoints = winnerPoints   //two players each pay 1500
                } else {
                    regularMinusPoints = winnerPoints * 3   //one player pays 3000
                }   //winner and minus points decided
                
            }
            for i in playerList.indices {
                if playerList[i].tenpai {
                    playerList[i].score += winnerPoints
                    playerList[i].tenpai = false
                } else {
                    playerList[i].score -= regularMinusPoints
                }   //winner and minus scored
            }
            //reset variables
            tenpaiCounter = 0
            winnerPoints = 0
            regularMinusPoints = 0
        }
        
        func restart() {
            windsList = ["東", "南", "西", "北"]
            player1.wind = windsList[0]
            player2.wind = windsList[1]
            player3.wind = windsList[2]
            player4.wind = windsList[3]
            player1.score = 25000
            player2.score = 25000
            player3.score = 25000
            player4.score = 25000
            playerList = [player1, player2, player3, player4]
            tenpaiCounter = 0
            winnerPoints = 0
            regularMinusPoints = 0
            riichiPot = 0
            han = 1
            winner = "東"
            loser = "南"
        }
        
        func rotateWinds() {
            let popped = windsList.popLast()
            windsList.insert(popped ?? "East", at: 0)
            
            playerList[0].wind = windsList[0]
            playerList[1].wind = windsList[1]
            playerList[2].wind = windsList[2]
            playerList[3].wind = windsList[3]
            
        }
        
    }
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

