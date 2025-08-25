//
//  ContentView.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 9/8/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
     //player1 is in charge of the scoreboard
    
    @State var timerDown = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timerUp = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timerLeft = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timerRight = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var sleepDelay = 1.5
    
    @State var enterPlayer1 = ""
    @State var enterPlayer2 = ""
    @State var enterPlayer3 = ""
    @State var enterPlayer4 = ""
    
    @State var firstPlace = ""
    @State var secondPlace = ""
    @State var thirdPlace = ""
    @State var fourthPlace = ""
    
    @State var playerNamesShuffleList: [String] = []
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
    
    @State var winner = ""
    @State var loser = ""
    @State var han = 1
    
    @State var windsList = ["", "東", "南", "西", "北"]
    
    @State var ron = false      //for displaying the ron picker
    @State var tsumo = false    //for displaying the tsumo picker
    @State var exhaust = false  //for displaying the exhaust picker
    @State var enterNames = true    //needs to be true!!
    @State var showNames = false    //for displaying the show names screen
    @State var displayResultsScreen = false //for displaying results screen!
    
    @State var newArr: [Player] = [
        Player(name: "player1", score: 25000, wind: "東", winner: false, loser: false, tenpai: false, riichi: false),
        Player(name: "player2", score: 25000, wind: "南", winner: false, loser: false, tenpai: false, riichi: false),
        Player(name: "player3", score: 25000, wind: "西", winner: false, loser: false, tenpai: false, riichi: false),
        Player(name: "player4", score: 25000, wind: "北", winner: false, loser: false, tenpai: false, riichi: false)
    ]

    @State var tenpaiCounter = 0
    @State var showDice = false
    @State var roundWind = "東"
    @State var downScoreChange = false
    @State var upScoreChange = false
    @State var leftScoreChange = false
    @State var rightScoreChange = false
    @State var downLosingPoints = 0
    @State var upLosingPoints = 0
    @State var leftLosingPoints = 0
    @State var rightLosingPoints = 0
    @State var downWinningPoints = 0
    @State var rightWinningPoints = 0
    @State var upWinningPoints = 0
    @State var leftWinningPoints = 0
    @State var downWinnerPointsUnchanged = true
    @State var downLosingPointsUnchanged = true
    @State var rightWinnerPointsUnchanged = true
    @State var rightLosingPointsUnchanged = true
    @State var upWinnerPointsUnchanged = true
    @State var upLosingPointsUnchanged = true
    @State var leftWinnerPointsUnchanged = true
    @State var leftLosingPointsUnchanged = true
    @State var timerOn = false
    @State var playerTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var timerTime = 24.0
    @State var hiddenTimerTime = 24.0
    @State var decimalSeconds = 10
    @State var maxTime = 24.0
    @State var showYaku = false
    var bottomPaddingForButtons = CGFloat(210)
    @State var threePlayerMode = false
    @State var editNames = false
    @State var dieRoll1 = "die.face.1"
    @State var dieRoll2 = "die.face.1"
    @State var ronList = [""]
    //@State var totalWinningPoints = 0
    
    var body: some View {
        ZStack {
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showYaku = true
                    } label: {
                        Image(systemName: "trophy").foregroundStyle(.black)
                    }
                    .padding(.init(top: 0, leading: 0, bottom: -10, trailing: 50))
                    .disabled(timerOn ? true : false)
                }
            }   //show yaku button
            
            VStack {
                Button {
                    rollDice()
                } label: {
                    Image(systemName: "dice")
                        .padding(.bottom, -8)
                        .foregroundStyle(.black)
                }
                .disabled(timerOn ? true : false)
                Menu {
                    Button("Reset") {
                        restart()
                    }
                    
                    Button("Cancel", role: .destructive) {
                        
                    }
                } label: {
                    Image("restarticon").padding().foregroundColor(.blue)
                }
                .disabled(timerOn ? true : false)
                Button {
                    timerOn = true
                } label: {
                    Image(systemName: "hourglass").foregroundColor(.black)
                        .padding(.init(top: -15, leading: 5, bottom: 15, trailing: 5))
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
                .disabled(timerOn ? true : false)
                Button {
                    displayResults()
                } label: {
                    Image(systemName: "line.3.horizontal").foregroundColor(.black)
                        .padding(5)
                }.disabled(timerOn ? true : false)

                
            }   //menu buttons
            .font(.system(size: 50))
            
            VStack {
                //top player
                Text(String(playerList[2].score))
                    //.frame(width: 200, height: 70)
                    .rotationEffect(Angle(degrees: 180))
                    .monospacedDigit()
                ZStack {
                    Menu {
                        Button("Ron") {
                            ron = true
                            playerList[2].winner = true
                            winner = playerList[2].wind
                            ronList.removeAll()
                            if !threePlayerMode {
                                loser = playerList[3].wind
                                ronList.append(playerList[3].wind)
                            } else {
                                loser = playerList[0].wind
                            }
                            ronList.append(playerList[0].wind)
                            ronList.append(playerList[1].wind)
                        }
                        Button("Tsumo") {
                            tsumo = true
                            playerList[2].winner = true
                            winner = playerList[2].wind
                            playerList[0].loser = true
                            playerList[1].loser = true
                            playerList[3].loser = true
                        }
                        Button("Cancel", role: .destructive) {
                            
                        }
                    } label: {
                        Text(playerList[2].wind).rotationEffect(Angle(degrees: 180))
                    }
                    .foregroundStyle(.blue)
                    .disabled(timerOn ? true : false)
                    .padding(.top, -30)
                }
                RiichiButton(player: playerList[2], riichi: playerList[2].riichi)
                    .onTapGesture {
                        if playerList[2].riichi {
                            playerList[2].riichi = false
                            playerList[2].tenpai = false
                            playerList[2].score += 1000
                            riichiPot -= 1000
                        } else {
                            playerList[2].riichi = true
                            playerList[2].tenpai = true
                            playerList[2].score -= 1000
                            riichiPot += 1000
                        }
                        
                    }
                Spacer()
                
                //bottom player
                RiichiButton(player: playerList[0], riichi: playerList[0].riichi)
                    .onTapGesture {
                        if playerList[0].riichi {
                            playerList[0].riichi = false
                            playerList[0].tenpai = false
                            playerList[0].score += 1000
                            riichiPot -= 1000
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
                        playerList[1].loser = true
                        playerList[2].loser = true
                        playerList[3].loser = true
                    }
                    Button("Ron") {
                        ron = true
                        playerList[0].winner = true
                        winner = playerList[0].wind
                        ronList.removeAll()
                        loser = playerList[1].wind
                        ronList.append(playerList[1].wind)
                        ronList.append(playerList[2].wind)
                        if !threePlayerMode {
                            ronList.append(playerList[3].wind)
                        }
                    }
                } label: {
                    Text(playerList[0].wind)
                }
                .foregroundStyle(.blue)
                .disabled(timerOn ? true : false)
                .padding(.bottom, -20)
                Text(String(playerList[0].score))
                    .frame(width: 200, height: 70)
                    //.background(.yellow)
                    .monospacedDigit()
            }   //top and bottom players
            .font(.system(size: 50))
            
            LazyHStack {
                LazyHStack {
                    Menu {
                        Button("Ron") {
                            ron = true
                            playerList[3].winner = true
                            winner = playerList[3].wind
                            ronList.removeAll()
                            loser = playerList[0].wind
                            ronList.append(playerList[0].wind)
                            ronList.append(playerList[1].wind)
                            ronList.append(playerList[2].wind)
                        }
                        Button("Tsumo") {
                            tsumo = true
                            playerList[3].winner = true
                            winner = playerList[3].wind
                            playerList[0].loser = true
                            playerList[1].loser = true
                            playerList[2].loser = true
                        }
                        Button("Cancel", role: .destructive) {
                            
                        }
                    } label: {
                        Text(playerList[3].wind)
                    }
                    .foregroundStyle(threePlayerMode ? .black: .blue)
                    .disabled(threePlayerMode ? true: false)
                    .disabled(timerOn ? true : false)
                    if (!threePlayerMode) {
                        Text(String(playerList[3].score))
                            .monospacedDigit()
                        
                    }
                }
                .frame(width: 200, height: 40)
                .padding(.init(top: 30, leading: 0, bottom: -70, trailing: 0))
                //.padding(.bottom, -80)
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
                            playerList[0].loser = true
                            playerList[2].loser = true
                            playerList[3].loser = true
                        }
                        Button("Ron") {
                            ron = true
                            playerList[1].winner = true
                            winner = playerList[1].wind
                            ronList.removeAll()
                            loser = playerList[2].wind
                            ronList.append(playerList[2].wind)
                            if !threePlayerMode {
                                ronList.append(playerList[3].wind)
                            }
                            ronList.append(playerList[0].wind)
                        }
                    } label: {
                        Text(playerList[1].wind)
                    }
                    .foregroundStyle(.blue)
                    .disabled(timerOn ? true : false)
                    Text(String(playerList[1].score))
                        .monospacedDigit()
                }
                .frame(width: 200, height: 40)
                .padding(.init(top: 30, leading: 0, bottom: -70, trailing: 0))
                //.padding(.bottom, -80)
                .rotationEffect(Angle(degrees: -90))
            }   //left and right players
            .font(.system(size: 50))
            
            HStack {
                RiichiButton(player: playerList[3], riichi: playerList[3].riichi)
                    .onTapGesture {
                        if playerList[3].riichi {
                            playerList[3].riichi = false
                            playerList[3].tenpai = false
                            playerList[3].score += 1000
                            riichiPot -= 1000
                        } else {
                            playerList[3].riichi = true
                            playerList[3].tenpai = true
                            playerList[3].score -= 1000
                            riichiPot += 1000
                        }
                    }
                    .rotationEffect(Angle(degrees: 90))
                    .padding(.trailing, -130)
                    .disabled(threePlayerMode ? true: false)
                    .opacity(threePlayerMode ? 0: 1)
                RiichiButton(player: playerList[1], riichi: playerList[1].riichi)
                    .onTapGesture {
                        if playerList[1].riichi {
                            playerList[1].riichi = false
                            playerList[1].tenpai = false
                            playerList[1].score += 1000
                            riichiPot -= 1000
                        } else {
                            playerList[1].riichi = true
                            playerList[1].tenpai = true
                            playerList[1].score -= 1000
                            riichiPot += 1000
                        }
                    }.rotationEffect(Angle(degrees: 90))
            }   //left and right riichi
            
            VStack {
                Spacer()
                HStack {
                    Button {
                        changeRoundWind()
                    } label: {
                        Text(roundWind)
                            .frame(width: 100, height: 100)
                            .padding(.init(top: -5, leading: 25, bottom: -30, trailing: -5))
                            .font(.system(size: 100))
                            .foregroundStyle(roundWind == "東" ? .gray : .yellow)
                            .background(roundWind == "東" ? .red : .green)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
            }   //round wind indicator
            
            ZStack {
                VStack {
                    if upScoreChange {
                        if playerList[2].winner {
                            Text("+" + String(upWinningPoints))
                                .frame(width: 80, height: 20)
                                .rotationEffect(.degrees(180))
                                .padding(.init(top: -10, leading: -20, bottom: 0, trailing: 0))
                                .onAppear {
                                    timerUp = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                                }
                                .onReceive(timerUp, perform: { _ in
                                    if upWinnerPointsUnchanged == true {
                                        sleep(UInt32(sleepDelay))
                                        upWinnerPointsUnchanged = false
                                    }
                                    upWinningPoints -= 10
                                    playerList[2].score += 10
                                    if upWinningPoints == 0 {
                                        timerUp.upstream.connect().cancel()
                                        upScoreChange = false
                                        upWinnerPointsUnchanged = true
                                        playerList[2].winner = false
                                        winner = ""
                                    }
                                })
                        }
                        //lost by ron
                        if playerList[2].wind == loser {
                            Text("-" + String(upLosingPoints))
                                .frame(width: 80, height: 20)
                                .rotationEffect(.degrees(180))
                                .padding(.init(top: -10, leading: -20, bottom: 0, trailing: 0))
                                .onAppear {
                                    timerUp = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                                }
                                .onReceive(timerUp, perform: { _ in
                                    if upLosingPointsUnchanged == true {
                                        sleep(UInt32(sleepDelay))
                                        upLosingPointsUnchanged = false
                                    }
                                    upLosingPoints -= 10
                                    playerList[2].score -= 10
                                    if upLosingPoints == 0 || upLosingPoints < 0 {
                                        timerUp.upstream.connect().cancel()
                                        upScoreChange = false
                                        loser = ""
                                    }
                                })

                        }
                        //in the case of losing to tsumo
                        if playerList[2].loser {
                            Text("-" + String(upLosingPoints))
                                .frame(width: 80, height: 20)
                                .rotationEffect(.degrees(180))
                                .padding(.init(top: -10, leading: -20, bottom: 0, trailing: 0))
                                .onAppear {
                                    timerUp = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                                }
                                .onReceive(timerUp, perform: { _ in
                                    if upLosingPointsUnchanged == true {
                                        sleep(UInt32(sleepDelay))
                                        upLosingPointsUnchanged = false
                                    }
                                    upLosingPoints -= 10
                                    playerList[2].score -= 10
                                    if upLosingPoints == 0 {
                                        timerUp.upstream.connect().cancel()
                                        upScoreChange = false
                                        playerList[2].loser = false
                                    }
                                })
                        }
                    }
                    Spacer()
                }   //top player
                
                VStack {
                    Spacer()
                    if downScoreChange {
                        //winner by ron
                        if playerList[0].winner {
                            Text("+" + String(downWinningPoints))
                                .frame(width: 80, height: 20)
                                .padding(.init(top: 0, leading: 20, bottom: -10, trailing: 0))
                                .onAppear {
                                    timerDown = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                                }
                                .onReceive(timerDown, perform: { _ in
                                    if downWinnerPointsUnchanged == true {
                                        sleep(UInt32(sleepDelay))
                                        downWinnerPointsUnchanged = false
                                    }
                                    playerList[0].score += 10
                                    downWinningPoints -= 10
                                    if downWinningPoints == 0 || downWinningPoints < 0 {
                                        timerDown.upstream.connect().cancel()
                                        downScoreChange = false
                                        downWinnerPointsUnchanged = true
                                        playerList[0].winner = false
                                        winner = ""
                                    }
                                })
                        }
                        //lost by ron
                        if playerList[0].wind == loser {
                            Text("-" + String(downLosingPoints))
                                .frame(width: 80, height: 20)
                                .padding(.init(top: 0, leading: 20, bottom: -10, trailing: 0))
                                .onAppear {
                                    timerDown = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                                }
                                .onReceive(timerDown, perform: { _ in
                                    if downLosingPointsUnchanged == true {
                                        sleep(UInt32(sleepDelay))
                                        downLosingPointsUnchanged = false
                                    }
                                    downLosingPoints -= 10
                                    playerList[0].score -= 10
                                    if downLosingPoints == 0 || downLosingPoints < 0 {
                                        timerDown.upstream.connect().cancel()
                                        downScoreChange = false
                                        loser = ""
                                    }
                                })

                        }
                        //in the case of losing to tsumo
                        if playerList[0].loser {
                            Text("-" + String(downLosingPoints))
                                .frame(width: 80, height: 20)
                                .padding(.init(top: 0, leading: 20, bottom: -10, trailing: 0))
                                .onAppear {
                                    timerDown = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                                }
                                .onReceive(timerDown, perform: { _ in
                                    if downWinnerPointsUnchanged == true {
                                        sleep(UInt32(sleepDelay))
                                        downWinnerPointsUnchanged = false
                                    }
                                    downLosingPoints -= 10
                                    playerList[0].score -= 10
                                    if downLosingPoints == 0 || downLosingPoints < 0 {
                                        timerDown.upstream.connect().cancel()
                                        downScoreChange = false
                                        playerList[0].loser = false
                                        downWinnerPointsUnchanged = true
                                    }
                                })
                        }
                    }
                }   //bottom player
                
                HStack {
                    if leftScoreChange {
                        if playerList[3].winner {
                            Text("+" + String(leftWinningPoints))
                                .frame(width: 80, height: 20)
                                .rotationEffect(.degrees(90))
                                .padding(.init(top: 80, leading: 15, bottom: 0, trailing: 0))
                                .onAppear {
                                    timerLeft = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                                }
                                .onReceive(timerLeft, perform: { _ in
                                    if leftWinnerPointsUnchanged == true {
                                        sleep(UInt32(sleepDelay))
                                        leftWinnerPointsUnchanged = false
                                    }
                                    leftWinningPoints -= 10
                                    playerList[3].score += 10
                                    if leftWinningPoints == 0 || leftWinningPoints < 0 {
                                        timerLeft.upstream.connect().cancel()
                                        leftScoreChange = false
                                        leftWinnerPointsUnchanged = true
                                        playerList[3].winner = false
                                        winner = ""
                                    }
                                })
                        }
                        //lost by ron
                        if playerList[3].wind == loser {
                            Text("-" + String(leftLosingPoints))
                                .frame(width: 80, height: 20)
                                .rotationEffect(.degrees(90))
                                .padding(.init(top: 80, leading: 15, bottom: 0, trailing: 0))
                                .onAppear {
                                    timerLeft = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                                }
                                .onReceive(timerLeft, perform: { _ in
                                    if leftLosingPointsUnchanged == true {
                                        sleep(UInt32(sleepDelay))
                                        leftLosingPointsUnchanged = false
                                    }
                                    leftLosingPoints -= 10
                                    playerList[3].score -= 10
                                    if leftLosingPoints == 0 || leftLosingPoints < 0 {
                                        timerLeft.upstream.connect().cancel()
                                        leftScoreChange = false
                                        loser = ""
                                    }
                                })

                        }
                        //in the case of losing to tsumo
                        if playerList[3].loser {
                            Text("-" + String(leftLosingPoints))
                                .frame(width: 80, height: 20)
                                .rotationEffect(.degrees(90))
                                .padding(.init(top: 80, leading: 15, bottom: 0, trailing: 0))
                                .onAppear {
                                    timerLeft = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                                }
                                .onReceive(timerLeft, perform: { _ in
                                    if leftLosingPointsUnchanged == true {
                                        sleep(UInt32(sleepDelay))
                                        leftLosingPointsUnchanged = false
                                    }
                                    leftLosingPoints -= 10
                                    playerList[3].score -= 10
                                    if leftLosingPoints == 0 || leftLosingPoints < 0 {
                                        timerLeft.upstream.connect().cancel()
                                        leftScoreChange = false
                                        playerList[3].loser = false
                                    }
                                })
                        }
                    }
                    Spacer()
                }   //left player
                
                HStack {
                    Spacer()
                    if rightScoreChange {
                        if playerList[1].winner {
                            Text("+" + String(rightWinningPoints))
                                .frame(width: 80, height: 20)
                                .rotationEffect(.degrees(-90))
                                .padding(.init(top: 0, leading: 0, bottom: 80, trailing: 15))
                                .onAppear {
                                    timerRight = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                                }
                                .onReceive(timerRight, perform: { _ in
                                    if rightWinnerPointsUnchanged == true {
                                        sleep(UInt32(sleepDelay))
                                        rightWinnerPointsUnchanged = false
                                    }
                                    rightWinningPoints -= 10
                                    playerList[1].score += 10
                                    if rightWinningPoints == 0 || rightWinningPoints < 0 {
                                        timerRight.upstream.connect().cancel()
                                        rightScoreChange = false
                                        rightWinnerPointsUnchanged = true
                                        playerList[1].winner = false
                                        winner = ""
                                    }
                                })
                        }
                        //lost by ron
                        if playerList[1].wind == loser {
                            Text("-" + String(rightLosingPoints))
                                .frame(width: 80, height: 20)
                                .rotationEffect(.degrees(-90))
                                .padding(.init(top: 0, leading: 0, bottom: 80, trailing: 15))
                                .onAppear {
                                    timerRight = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                                }
                                .onReceive(timerRight, perform: { _ in
                                    if rightLosingPointsUnchanged == true {
                                        sleep(UInt32(sleepDelay))
                                        rightLosingPointsUnchanged = false
                                    }
                                    rightLosingPoints -= 10
                                    playerList[1].score -= 10
                                    if rightLosingPoints == 0 || rightLosingPoints < 0 {
                                        timerRight.upstream.connect().cancel()
                                        rightScoreChange = false
                                        loser = ""
                                    }
                                })

                        }
                        //in the case of losing to tsumo
                        if playerList[1].loser {
                            Text("-" + String(rightLosingPoints))
                                .frame(width: 80, height: 20)
                                .rotationEffect(.degrees(-90))
                                .padding(.init(top: 0, leading: 0, bottom: 80, trailing: 15))
                                .onAppear {
                                    timerRight = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                                }
                                .onReceive(timerRight, perform: { _ in
                                    if rightLosingPointsUnchanged == true {
                                        sleep(UInt32(sleepDelay))
                                        rightLosingPointsUnchanged = false
                                    }
                                    rightLosingPoints -= 10
                                    playerList[1].score -= 10
                                    if rightLosingPoints == 0 || rightLosingPoints < 0 {
                                        timerRight.upstream.connect().cancel()
                                        rightScoreChange = false
                                        playerList[1].loser = false
                                    }
                                })
                        }
                    }
                }   //right player
            }   //score change
            
            if timerOn {
                ZStack {
                    Circle()
                        .frame(width: 135, height: 135)
                        .foregroundStyle(.white)
                    HStack {
                        Text(String(format: "%.0f", timerTime))
                            .font(.system(size: timerTime > 9 ? 65: 80))
                            .monospacedDigit()
                            .padding(.init(top: 0, leading: 10, bottom: 0, trailing: 0))
                        Text(decimalSeconds == 10 ? ".0": "." + String(decimalSeconds))
                            .monospacedDigit()
                            .padding(.init(top: 0, leading: -10, bottom: -20, trailing: 0))
                    }
                    .onAppear {
                        hiddenTimerTime = maxTime
                        timerTime = maxTime
                        decimalSeconds = 9
                        playerTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    }
                    .onReceive(playerTimer, perform: { _ in
                        hiddenTimerTime -= 0.1
                        decimalSeconds -= 1
                        if decimalSeconds < 0 {
                            decimalSeconds = 9
                            timerTime -= 1
                        }
                        if hiddenTimerTime < 0 && decimalSeconds == 0 {
                            //hiddenTimerTime = 0
                            timerTime = 0
                            playerTimer.upstream.connect().cancel()
                            AudioServicesPlaySystemSound(1031)
//                            hiddenTimerTime = maxTime
//                            timerTime = maxTime
//                            decimalSeconds = 10
                        }
                    })
                    Circle()
                        .stroke(AngularGradient(gradient: Gradient(colors: roundWind == "東" ? [.red, .gray] : [.green, .yellow]), center: .center), style: StrokeStyle(
                            lineWidth: 15,
                            lineCap: .round
                        )).opacity(0.5)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 120, height: 120)
                    Circle()
                        .trim(from: 0, to: (hiddenTimerTime + 1)/(maxTime + 1))
                        .stroke(AngularGradient(gradient: Gradient(colors: roundWind == "東" ? [.red, .gray] : [.green, .yellow]), center: .center), style: StrokeStyle(
                            lineWidth: 15,
                            lineCap: .round
                        ))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut, value: hiddenTimerTime/maxTime)
                        .frame(width: 120, height: 120)
                }
                .frame(width: 150, height: 150)
                .onTapGesture {
                    hiddenTimerTime = maxTime
                    timerTime = maxTime
                    decimalSeconds = 9
                    playerTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                }
                .onLongPressGesture {
                    timerOn = false
                }
            }
            
            if showDice {
                ZStack {
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.7)
                    HStack {
                        Image(systemName: dieRoll1)
                        Image(systemName: dieRoll2)
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 100))
                    VStack {
                        Spacer()
                        Button("done") {
                            showDice = false
                        }
                        .font(.system(size: 30))
                        .padding(.bottom, bottomPaddingForButtons)
                    }
                    
                }
                .ignoresSafeArea()
            }
            
            if ron {
                ZStack {
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.6)
                        .onTapGesture {
                            ron = false
                            winner = ""
                            loser = ""
                            han = 1
                            for i in playerList.indices {
                                playerList[i].winner = false
                            }
                        }
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(width: 420, height: 250)
                            .cornerRadius(15)
                        HStack (spacing: -10){
                            VStack {
                                Text("Loser:")
                                Picker("", selection: $loser) {
                                    ForEach(self.ronList, id: \.self){wind in
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
                                    //Text("Double Yakuman")
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
                        .buttonStyle(.plain)
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
                        .onTapGesture {
                            tsumo = false
                            winner = ""
                            loser = ""
                            han = 1
                            for i in playerList.indices {
                                playerList[i].winner = false
                                playerList[i].loser = false
                            }
                        }
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
                                if !playerList[2].riichi {
                                    playerList[2].tenpai.toggle()
                                }
                        }
                        Spacer()
                        TenpaiButton(player: playerList[0], tenpai: playerList[0].tenpai)
                            .onTapGesture {
                                if !playerList[0].riichi {
                                    playerList[0].tenpai.toggle()
                                }
                        }
                    }
                    .padding(50)
                    HStack {
                        TenpaiButton(player: playerList[3], tenpai: playerList[3].tenpai)
                            .rotationEffect(Angle(degrees: 90))
                            .onTapGesture {
                                if !playerList[3].riichi {
                                    playerList[3].tenpai.toggle()
                                }
                            }
                            .opacity(threePlayerMode ? 0: 1)
                        Spacer()
                        TenpaiButton(player: playerList[1], tenpai: playerList[1].tenpai)
                            .rotationEffect(Angle(degrees: -90))
                            .onTapGesture {
                                if !playerList[1].riichi {
                                    playerList[1].tenpai.toggle()
                                }
                        }
                    }
                    .padding(.horizontal, -20)
                    VStack {
                        Spacer()
                        Button("done") {
                            scoreExhaust()
                        }
                        .font(.system(size: 30))
                        .padding(.bottom, bottomPaddingForButtons)
                    }
                }.ignoresSafeArea()
            }
            
            if enterNames {
                ZStack {
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.6)
                    VStack {
                        Text("Enter player names")
                            .foregroundColor(.white)
                            .padding(.top, -40)
                        TextField(
                            "Enter player name",
                            text: $enterPlayer1)
                        .textFieldStyle(.roundedBorder)
                        TextField(
                            "Enter player name",
                            text: $enterPlayer2)
                        .textFieldStyle(.roundedBorder)
                        TextField(
                            "Enter player name",
                            text: $enterPlayer3)
                        .textFieldStyle(.roundedBorder)
                        TextField(
                            "Enter player name",
                            text: $enterPlayer4)
                        .textFieldStyle(.roundedBorder)
                        .opacity(threePlayerMode ? 0: 1)
                    }
                    .font(.system(size: 30))
                    .foregroundColor(.black)
                    .padding([.horizontal, .bottom], 40)
                    VStack {
                        Spacer()
                        Button("submit") {
                            if (editNames) {
                                editNames = false
                            } else {
                                decideSeats()
                            }
                            enterNames = false
                            showNames = true
                        }.font(.system(size: 30))
                            .padding(.bottom, bottomPaddingForButtons)
                    }
                }.ignoresSafeArea()
            }
            
            if showNames {
                ZStack {
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.6)
                    VStack {
                        Text(playerList[2].name)
                            .frame(width: 400, height: 30)
                            .padding(.init(top: 0, leading: 0, bottom: 70, trailing: 0))
                            .rotationEffect(Angle(degrees: 180))
                            .onLongPressGesture {
                                editNames = true
                                showNames = false
                                enterNames = true
                            }
                        Spacer()
                        Text(playerList[0].name)
                            .frame(width: 400, height: 30)
                            .padding(.init(top: 0, leading: 0, bottom: 50, trailing: 0))
                            .onLongPressGesture {
                                editNames = true
                                showNames = false
                                enterNames = true
                            }
                    }
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    HStack {
                        Text(playerList[3].name)
                            .frame(width: 400, height: 30)
                            .padding(.init(top: 230, leading: 0, bottom: 0, trailing: 0))
                            .rotationEffect(Angle(degrees: 90))
                            .onLongPressGesture {
                                editNames = true
                                showNames = false
                                enterNames = true
                            }
                            .opacity(threePlayerMode ? 0: 1)
                        Spacer()
                    }
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    HStack {
                        Spacer()
                        Text(playerList[1].name)
                            .frame(width: 400, height: 30)
                            .padding(.init(top: 230, leading: 0, bottom: 0, trailing: 0))
                            .rotationEffect(Angle(degrees: -90))
                            .onLongPressGesture {
                                editNames = true
                                showNames = false
                                enterNames = true
                            }
                    }
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    VStack {
                        Spacer()
                        Button("start") {
                            showNames = false
                        }.font(.system(size: 30))
                            .padding(.bottom, bottomPaddingForButtons)
                    }
                }
                .ignoresSafeArea()
            }
            
            if displayResultsScreen {
                ZStack {
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.7)
                    VStack {
                        Text(newArr[0].name + ": " + String(newArr[0].score))
                            .font(.system(size: 50))
                        Text(newArr[1].name + ": " + String(newArr[1].score))
                            .font(.system(size: 48))
                        Text(newArr[2].name + ": " + String(newArr[2].score))
                            .font(.system(size: 46))
                        Text(newArr[3].name + ": " + String(newArr[3].score))
                            .font(.system(size: 44))
                            .opacity(threePlayerMode ? 0: 1)
                        
                    }
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .padding(40)
                    VStack {
                        Spacer()
                        Button("done") {
                            displayResultsScreen = false
                        }.font(.system(size: 30))
                            .padding(.bottom, bottomPaddingForButtons)
                    }
                }.ignoresSafeArea()
            }
            
            if showYaku {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundStyle(.white)
                VStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text("1 Han (Closed)\n")
                                .font(.title2)
                            Text("門前自摸(めんぜんつも)(**Tsumo**, \nFully Concealed Hand) - self draw")
                            Divider()
                            Text("立直(リーチ)(**Riichi**) - no pon or chii")
                            Divider()
                            Text("一発(イッパツ)(**Ippatsu**) - win within first rotation after riichi, also can't be interrupted by tile calls")
                            Divider()
                            Text("平和(ピンフ)(**Pinfu**) - all sequences and must end with a two-sided wait")
                            Divider()
                            Text("一盃口(イーペイコー)\n(**Pure Double Sequence**) - 112233 kind of double sequence\n")
                            
                            Text("1 Han\n")
                                .font(.title2)
                            Text("海底撈月(ハイテイラオユエ)\n(**Under the Sea**) - Tsumo with the last drawn tile from the wall")
                            Divider()
                            Text("河底撈魚(ホウテイラオユイ)\n(**Under the River**) - Ron with the last discarded tile")
                            Divider()
                            Text("嶺上開花(リンシャンカイホウ)\n(**After a Kan**) - win with a tile drawn from the dead wall immediately after calling a Kan")
                            Divider()
                            Text("搶槓(チャンカン)(**Robbing a Kan**) - calling Ron on another player's Kan (when you have a Tenpai for Thirteen Orphans, you can call on a Closed Kan)")
                            Divider()
                            Text("断幺九(タンヤオ)(**All Simples**) - winning with no honor or terminal tiles (2-8 number tiles only)")
                            Divider()
                            Text("役牌(**やくはい**) - a hand with at least one group of dragon, round wind, or seat wind tiles\n")
                            
                            Text("2 Han\n")
                                .font(.title2)
                            Text("両立直(ダブリー)(**Double Riichi**) - declare Riichi with your starting hand before any tiles are called")
                            Divider()
                            Text("全帯幺九(チャンタ)(**Half Outside Hand**) - every sequence, triplet and pair contains at least one terminal tile or honor tiles (-1 Han if open)")
                            Divider()
                            Text("三色同順(サンショクドウジュン)(**Mixed Triple Sequence**) - three sequences with the same numbers out of the three different number tile suits (-1 Han if open)")
                            Divider()
                            Text("一気通貫(イッキツウカン)(**Pure Straight**) - complete sequence 1-9 (-1 Han if open)")
                            Divider()
                            Text("対々(トイトイ)(**All Triplets**) - all triplets (or quads), no sequences")
                            Divider()
                            Text("三暗刻(サンアンコウ)(**Three Concealed Triplets**) - three sets of triplets (or quads) that were formed without calling any tiles (the fourth can be open)")
                            Divider()
                            Text("三色同刻(サンショクドウコウ)(**Triple Triplets**) - three triplets with the same number in each suit")
                            Divider()
                            Text("三槓子(サンカンツ)(**Three Kans**) - three Kans, may be open")
                            Divider()
                            Text("七対子(チートイツ)(**Seven Pairs**) - seven pairs, closed only")
                            Divider()
                            Text("混老頭(ホンロウトウ)(**All Terminals and Honors**) - nothing but terminals and honors (may be considered as 4 Han because it is impossible to score this hand without Seven Pairs or All Triples), may be open")
                            Divider()
                            Text("小三元(ショウサンゲン)(**Little Three Dragons**) - two triplets of dragon tiles plus a pair of the third, may be open\n")
                            
                            Text("3 Han\n")
                                .font(.title2)
                            Text("混一色(ホンイーソー)(**Half Flush**) - single suit with honor tiles (-1 Han if open)")
                            Divider()
                            Text("純全帯么(ジュンチャン)(**Fully Outside Hand**) - all sets contain at least one terminal tile (-1 Han if open)")
                            Divider()
                            Text("二盃口(リャンペイコー)(**Twice Pure Double Sequence**) - two sets of Pure Double Sequence in two different suits (doesn't combine with Seven Pairs)(closed only)\n")
                            
                            Text("6 Han\n")
                                .font(.title2)
                            Text("清一色(チンイーソー)(**Full Flush**) - same suit of number tiles (-1 Han if open)\n")
                            
                            Text("Mangan\n")
                                .font(.title2)
                            Text("流し満貫(ナガシマンガン)(**Mangan at Draw**) - all your discards were terminal or honors and no one called any of your tiles (5 Han)\n")
                            
                            Text("Yakuman\n")
                                .font(.title2)
                            Text("数え役満(**かぞえやくまん**) - if your hand adds up to 13+ Han")
                            Divider()
                            Text("国士無双(コクシムソウ)(**Thirteen Orphans**) - 191919 of each suit, all four winds, and all three dragons plus a duplicate of any one of those tiles")
                            Divider()
                            Text("四暗刻(スーアンコウ)(**Four Concealed Triplets**) - four closed triplets (closed only, you can only call the last tile for the pair)")
                            Divider()
                            Text("大三元(ダイサンゲン)(**Big Three Dragons**) - three triplets of all three dragons")
                            Divider()
                            Text("小四喜(ショウスーシー)(**Four Little Winds**) - three triplets or quads of wind tiles, plus a pair of the fourth")
                            Divider()
                            Text("大四喜(ダイスーシー)(**Big Four Winds**) - four triplets or quads of all four winds")
                            Divider()
                            Text("字一色(ツーイーソー)(**All Honors**) - nothing but triplets of honor tiles")
                            Divider()
                            Text("清老頭(チンロウトウ)(**All Terminals**) - nothing but triplets of terminal tiles")
                            Divider()
                            Text("緑一色(リューイーソー)(**All Green**) - nothing but sequences or triplets of green tiles (23468 bamboo and/or green dragon)")
                            Divider()
                            Text("九連宝燈(チューレンポートウ)(**Nine Gates**) - 1112345678999 of character tiles plus any extra of one of these tiles (closed only)")
                            Divider()
                            Text("四槓子(スーカンツ)(**Four Quads**) - four open or closed Kan")
                            Divider()
                            Text("天和(テンホー)(**Blessing of Heaven**) - win by Tsumo as the dealer in the first turn with the first draw")
                            Divider()
                            Text("地和(チーホー)(**Blessing of Earth**) - win by Tsumo as a non-dealer in the first turn before any tiles are called\n")
                        }
                        .frame(maxWidth: 330, alignment: .leading)
                    }
                    Button("done") {
                        showYaku = false
                    }
                }
            }
            
        }.onAppear(perform: {
            restart()
            timerDown.upstream.connect().cancel()
            timerUp.upstream.connect().cancel()
            timerLeft.upstream.connect().cancel()
            timerRight.upstream.connect().cancel()
            playerTimer.upstream.connect().cancel()
        })
    }
    
    func rollDice() {
        showDice = true
        dieRoll1 = dieFace(dieRoll: Int.random(in: 1...6))
        dieRoll2 = dieFace(dieRoll: Int.random(in: 1...6))
    }
    
    func dieFace(dieRoll: Int) -> String {
        switch (dieRoll) {
        case 1:
            return "die.face.1.fill"
        case 2:
            return "die.face.2.fill"
        case 3:
            return "die.face.3.fill"
        case 4:
            return "die.face.4.fill"
        case 5:
            return "die.face.5.fill"
        case 6:
            return "die.face.6.fill"
        default:
            return "die.face.1"
        }
    }
    
    func changeRoundWind() {
        if roundWind == "東" {
            roundWind = "南"
        } else {
            roundWind = "東"
        }
    }
    
    func decideSeats() {
        playerNamesShuffleList.append(enterPlayer1)
        playerNamesShuffleList.append(enterPlayer2)
        playerNamesShuffleList.append(enterPlayer3)
        playerNamesShuffleList.append(enterPlayer4)
        for i in playerNamesShuffleList.indices {
            if playerNamesShuffleList[i] == "" {
                playerNamesShuffleList[i] = "player" + String(i + 1)
            }
        }
        if (playerNamesShuffleList[0] != "player1" && playerNamesShuffleList[3] == "player4") {
            threePlayerMode = true
            playerNamesShuffleList.remove(at: 3)
            playerList[0].score = 35000
            playerList[1].score = 35000
            playerList[2].score = 35000
            playerList[3].score = -100000 // just to be sure it doesn't appear in the score list
        }
        playerNamesShuffleList.shuffle()
        for i in playerNamesShuffleList.indices {
            playerList[i].name = playerNamesShuffleList[i]
            print(playerNamesShuffleList[i])
        }
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
        
        downScoreChange = true
        upScoreChange = true
        if (!threePlayerMode) {
            leftScoreChange = true
        }
        rightScoreChange = true
        
        if winner == "東" {
            winnerPoints = winnerPoints + winnerPoints / 2
            regularMinusPoints = winnerPoints / 3
            if (threePlayerMode) {
                // North isn't there to pay
                winnerPoints -= regularMinusPoints
            }
        } else {
            dealerMinusPoints = winnerPoints / 2
            regularMinusPoints = dealerMinusPoints / 2
            if (threePlayerMode) {
                // North isn't there to pay
                winnerPoints -= regularMinusPoints
            }
        }
        
        for i in playerList.indices {
            //handle winner
            if playerList[i].winner {
                switch i {
                case 0: downWinningPoints = winnerPoints + riichiPot
                case 1: rightWinningPoints = winnerPoints + riichiPot
                case 2: upWinningPoints = winnerPoints + riichiPot
                case 3: leftWinningPoints = winnerPoints + riichiPot
                default: print("something went wrong")
                }
                //totalWinningPoints = winnerPoints + riichiPot
                riichiPot = 0
            } else {
                //handle the losers
                if playerList[i].wind == "東"{
                    switch i {
                    case 0: downLosingPoints = dealerMinusPoints
                    case 1: rightLosingPoints = dealerMinusPoints
                    case 2: upLosingPoints = dealerMinusPoints
                    case 3: leftLosingPoints = dealerMinusPoints
                    default: print("something went wrong")
                    }
                } else {
                    switch i {
                    case 0: downLosingPoints = regularMinusPoints
                    case 1: rightLosingPoints = regularMinusPoints
                    case 2: upLosingPoints = regularMinusPoints
                    case 3: leftLosingPoints = regularMinusPoints
                    default: print("something went wrong")
                    }
                }
            }
            playerList[i].riichi = false
            playerList[i].tenpai = false
            han = 1
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
                switch i {
                case 0: downScoreChange = true
                case 1: rightScoreChange = true
                case 2: upScoreChange = true
                case 3: leftScoreChange = true
                default: print("something went wrong")
                }
                if playerList[i].wind == "東" {
                    winnerPoints = winnerPoints + winnerPoints / 2
                }
                switch i {
                case 0: downWinningPoints = winnerPoints + riichiPot
                case 1: rightWinningPoints = winnerPoints + riichiPot
                case 2: upWinningPoints = winnerPoints + riichiPot
                case 3: leftWinningPoints = winnerPoints + riichiPot
                default: print("something went wrong")
                }
                //totalWinningPoints = winnerPoints + riichiPot
                riichiPot = 0
            }
            playerList[i].riichi = false
            playerList[i].tenpai = false
        }
        for i in playerList.indices {
            if playerList[i].wind == loser {
                switch i {
                case 0:
                    downScoreChange = true
                    downLosingPoints = winnerPoints
                case 1:
                    rightScoreChange = true
                    rightLosingPoints = winnerPoints
                case 2:
                    upScoreChange = true
                    upLosingPoints = winnerPoints
                case 3:
                    leftScoreChange = true
                    leftLosingPoints = winnerPoints
                default: print("something went wrong")
                }
            }
        }
        han = 1
    }
    
    func scoreExhaust() {
        
        //count the tenpai
        for i in playerList.indices {
            if playerList[i].tenpai {
                tenpaiCounter += 1
            }
            playerList[i].riichi = false    //pot stays the same
        }
        //if no one or everyone is in tenpai nothing happens
        if threePlayerMode && (tenpaiCounter == 0 || tenpaiCounter == 3) {
            tenpaiCounter = 1
            winnerPoints = 0
        } else if (tenpaiCounter == 0 || tenpaiCounter == 4) {
            tenpaiCounter = 1   //just paranoid about dividing by 0
            winnerPoints = 0
        } else {
            downScoreChange = true
            upScoreChange = true
            if (!threePlayerMode) {
                leftScoreChange = true
            }
            rightScoreChange = true
            if threePlayerMode {
                winnerPoints = 2000 / tenpaiCounter
            } else {
                winnerPoints = 3000 / tenpaiCounter
            }
            if threePlayerMode {
                if tenpaiCounter == 1 {
                    regularMinusPoints = winnerPoints / 2 // each player pays 1000
                } else if tenpaiCounter == 2 {
                    regularMinusPoints = 2000 // one player pays the other two 1000 each
                }
            } else { // regular four player
                if tenpaiCounter == 1 {
                    regularMinusPoints = winnerPoints / 3   //each player pays 1000
                } else if tenpaiCounter == 2 {
                    regularMinusPoints = winnerPoints   //two players each pay 1500
                } else {
                    regularMinusPoints = winnerPoints * 3   //one player pays 3000
                }
            }   
            //winner and minus points decided
            for i in playerList.indices {
                if playerList[i].tenpai {
                    switch i {
                    case 0:
                        downWinningPoints = winnerPoints
                        playerList[0].winner = true
                    case 1:
                        rightWinningPoints = winnerPoints
                        playerList[1].winner = true
                    case 2:
                        upWinningPoints = winnerPoints
                        playerList[2].winner = true
                    case 3:
                        leftWinningPoints = winnerPoints
                        playerList[3].winner = true
                    default: print("something went wrong")
                    }
                    playerList[i].tenpai = false
                } else {
                    playerList[i].loser = true
                    switch i {
                    case 0: downLosingPoints = regularMinusPoints
                    case 1: rightLosingPoints = regularMinusPoints
                    case 2: upLosingPoints = regularMinusPoints
                    case 3: leftLosingPoints = regularMinusPoints
                    default: print("something went wrong")
                    }
                }   //winner and minus scored, handled in score change in the above view
            }
            
        }
        
        exhaust = false
        //reset variables
        tenpaiCounter = 0
        winnerPoints = 0
        regularMinusPoints = 0
        timerOn = false
        playerTimer.upstream.connect().cancel()
        hiddenTimerTime = 24.0
        decimalSeconds = 10
        maxTime = 24.0
    }
    
    func restart() {
        playerNamesShuffleList.removeAll()
        enterPlayer1 = ""
        enterPlayer2 = ""
        enterPlayer3 = ""
        enterPlayer4 = ""
        enterNames = true
        threePlayerMode = false
        windsList = ["","東", "南", "西", "北"]
        player1.wind = windsList[1]
        player2.wind = windsList[2]
        player3.wind = windsList[3]
        player4.wind = windsList[4]
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
        winner = ""
        loser = ""
        roundWind = "東"
        timerOn = false
        timerTime = 24.0
        hiddenTimerTime = 24.0
        decimalSeconds = 10
        maxTime = 24.0
        playerTimer.upstream.connect().cancel()
    }
    
    func rotateWinds() {
        if (threePlayerMode) {
            let poppedSecondToLast = windsList.remove(at: 3)
            windsList.insert(poppedSecondToLast, at: 1)
        }
        else {
            let popped = windsList.popLast()
            windsList.insert(popped ?? "East", at: 1)
        }
        playerList[0].wind = windsList[1]
        playerList[1].wind = windsList[2]
        playerList[2].wind = windsList[3]
        playerList[3].wind = windsList[4]
        
    }
    
    func displayResults() {
        newArr = playerList.sorted { $0.score > $1.score }
        displayResultsScreen = true
    }
        
    }
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

