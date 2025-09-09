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
    @StateObject var audioManager = AudioManager()
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
    @State var extraRounds = false
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
    var bottomPaddingForButtons = CGFloat(203)
    @State var threePlayerMode = false
    @State var editNames = false
    @State var dieRoll1 = "die.face.1"
    @State var dieRoll2 = "die.face.1"
    @State var ronList = [""]
    @State var calculateFu = true
    @State var fu = 20    // default starting fu
    @State var quick3 = false
    @State var showFu = false
    @State var addingFu = 20
    @State var riichiPotIndicator = 0
    @State var honbaCount = 0
    @State var displayScoring = false
    @State var scoringScreen = false
    
    @State var basePoints = 0
    @State var winnerPoints = 0
    @State var dealerPayment = 0
    @State var nonDealerPayment = 0
    @State var wasTsumo = false
    
    @State var multiplier = 4
    @State var wasRon = false
    
    @State private var showHonbaInfo = false
    
    @State private var showLeftKanji = false
    @State private var showRightKanji = false
    @State private var showTopKanji = false
    @State private var showBottomKanji = false
    
    var body: some View {
        ZStack {
            //show yaku button
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
            }
            
            //show fu button
            ShowFuButton(showFu: $showFu, timerOn: $timerOn, ron: $ron, tsumo: $tsumo, calculateFu: $calculateFu, han: $han)
            
            //menu buttons
            VStack {
                Button {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        showDice = false
                    }
                    rollDice()
                } label: {
                    Image(systemName: "dice")
                        // .padding(.bottom, -8)
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
                    Image("radioactive")
                        .resizable()
                        .frame(width: 45, height: 45)
                        // .renderingMode(.template)
                        .padding(.init(top: 20, leading: 5, bottom: 25, trailing: 5))
                        // .foregroundStyle(.red)
                }
                .disabled(timerOn)
                Button {
                    timerOn = true
                } label: {
                    Image(systemName: "hourglass").foregroundColor(.black)
                        .padding(.init(top: -5, leading: 5, bottom: 15, trailing: 5))
                }
                Button {
                    rotateWinds()
                } label: {
                    Image(systemName: "rotate.left")
                        .padding(.bottom, 5)
                        .padding(.top, -5)
                        .foregroundColor(.black)
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

                
            }
            .font(.system(size: 50))
            
            if showTopKanji {
                Text("一 二 三 四 五 六 七 八 九")
                    .offset(x: 0, y: 425)
                    .font(.system(size: 20))
                    .rotationEffect(Angle(degrees: 180))
            }
            if showBottomKanji {
                Text("一 二 三 四 五 六 七 八 九")
                    .font(.system(size: 20))
                    .offset(x: 0, y: 425)
            }
            if showLeftKanji {
                Text("一 二 三 四 五 六 七 八 九")
                    .font(.system(size: 20))
                    .rotationEffect(Angle(degrees: 90))
                    .offset(x: -195)
            }
            if showRightKanji {
                Text("一 二 三 四 五 六 七 八 九")
                    .font(.system(size: 20))
                    .rotationEffect(Angle(degrees: -90))
                    .offset(x: 195)
            }
            //top and bottom players
            VStack {
                //top player
                Text(String(playerList[2].score))
                    //.frame(width: 200, height: 70)
                    .rotationEffect(Angle(degrees: 180))
                    .monospacedDigit()
                    .onTapGesture {
                        showTopKanji.toggle()
                    }
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
                            riichiPotIndicator = riichiPot / 1000
                        } else {
                            audioManager.playSound()
                            playerList[2].riichi = true
                            playerList[2].tenpai = true
                            playerList[2].score -= 1000
                            riichiPot += 1000
                            riichiPotIndicator = riichiPot / 1000
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
                            riichiPotIndicator = riichiPot / 1000
                        } else {
                            audioManager.playSound()
                            playerList[0].riichi = true
                            playerList[0].tenpai = true
                            playerList[0].score -= 1000
                            riichiPot += 1000
                            riichiPotIndicator = riichiPot / 1000
                        }
                    }
                Menu {
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
                    .onTapGesture {
                        showBottomKanji.toggle()
                    }
            }
            .font(.system(size: 50))
            
            //left and right players
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
                    } label: {
                        Text(playerList[3].wind)
                    }
                    .foregroundStyle(threePlayerMode ? .black: .blue)
                    .disabled(threePlayerMode ? true: false)
                    .disabled(timerOn ? true : false)
                    if (!threePlayerMode) {
                        Text(String(playerList[3].score))
                            .monospacedDigit()
                            .onTapGesture {
                                showLeftKanji.toggle()
                            }
                        
                    }
                }
                .frame(width: 200, height: 40)
                .padding(.init(top: 30, leading: 0, bottom: -70, trailing: 0))
                //.padding(.bottom, -80)
                .rotationEffect(Angle(degrees: 90))
                
                Spacer()
                LazyHStack {
                    Menu {
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
                        .onTapGesture {
                            showRightKanji.toggle()
                        }
                }
                .frame(width: 200, height: 40)
                .padding(.init(top: 30, leading: 0, bottom: -70, trailing: 0))
                //.padding(.bottom, -80)
                .rotationEffect(Angle(degrees: -90))
            }
            .font(.system(size: 50))
            
            //left and right riichi
            HStack {
                RiichiButton(player: playerList[3], riichi: playerList[3].riichi)
                    .onTapGesture {
                        if playerList[3].riichi {
                            playerList[3].riichi = false
                            playerList[3].tenpai = false
                            playerList[3].score += 1000
                            riichiPot -= 1000
                            riichiPotIndicator = riichiPot / 1000
                        } else {
                            audioManager.playSound()
                            playerList[3].riichi = true
                            playerList[3].tenpai = true
                            playerList[3].score -= 1000
                            riichiPot += 1000
                            riichiPotIndicator = riichiPot / 1000
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
                            riichiPotIndicator = riichiPot / 1000
                        } else {
                            audioManager.playSound()
                            playerList[1].riichi = true
                            playerList[1].tenpai = true
                            playerList[1].score -= 1000
                            riichiPot += 1000
                            riichiPotIndicator = riichiPot / 1000
                        }
                    }.rotationEffect(Angle(degrees: 90))
            }
            
            //round wind indicator
            VStack {
                Spacer()
                HStack {
                    Button {
                        changeRoundWind()
                    } label: {
                        if extraRounds {
                            Text(roundWind)
                                .frame(width: 100, height: 100)
                                .padding(.init(top: -5, leading: 25, bottom: -30, trailing: -5))
                                .font(.system(size: 100))
                                .foregroundStyle(roundWind == "西" ? .purple : .yellow)
                                .background(roundWind == "西" ? .yellow : .mint)
                                .onLongPressGesture {
                                    roundWind = "東"
                                    extraRounds.toggle()
                                }
                        } else {
                            Text(roundWind)
                                .frame(width: 100, height: 100)
                                .padding(.init(top: -5, leading: 25, bottom: -30, trailing: -5))
                                .font(.system(size: 100))
                                .foregroundStyle(roundWind == "東" ? .gray : .yellow)
                                .background(roundWind == "東" ? .red : .green)
                                .onLongPressGesture {
                                    roundWind = "西"
                                    extraRounds.toggle()
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
            }
            
            //score change
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
            }
            
            // riichi pot and honba indicator
            VStack {
                Button {
                    showHonbaInfo = true
                } label: {
                    HStack {
                        // riichi pot
                        VStack {
                            ZStack {
                                Rectangle()
                                    .frame(width: 10, height: 30)
                                    .border(.black, width: 1)
                                    .foregroundColor(.white)
                                Circle()
                                    .frame(height: 5)
                                    .foregroundColor(.red)
                            }
                            Text(String(riichiPotIndicator))
                                .font(.caption)
                        }
                        // honba indicator
                        VStack {
                            ZStack {
                                Rectangle()
                                    .frame(width: 10, height: 30)
                                    .border(.black, width: 1)
                                    .foregroundColor(.white)
                                VStack(spacing: 2) {
                                    HStack(spacing: 1) {
                                        Circle()
                                            .frame(height: 2)
                                            .foregroundColor(.black)
                                        Circle()
                                            .frame(height: 2)
                                            .foregroundColor(.black)
                                    }
                                    HStack(spacing: 1) {
                                        Circle()
                                            .frame(height: 2)
                                            .foregroundColor(.black)
                                        Circle()
                                            .frame(height: 2)
                                            .foregroundColor(.black)
                                    }
                                    HStack(spacing: 1) {
                                        Circle()
                                            .frame(height: 2)
                                            .foregroundColor(.black)
                                        Circle()
                                            .frame(height: 2)
                                            .foregroundColor(.black)
                                    }
                                    HStack(spacing: 1) {
                                        Circle()
                                            .frame(height: 2)
                                            .foregroundColor(.black)
                                        Circle()
                                            .frame(height: 2)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            Text(String(honbaCount))
                                .font(.caption)
                        }
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .alert("", isPresented: $showHonbaInfo) {
                    Button("Ah, okay", role: .cancel) { }
                } message: {
                    Text("\(riichiPot) points in the riichi pot\nHonba count: \(honbaCount)\n\nThe honba count increases when either the dealer wins or there is an exhaustive draw and at least one person was in tenpai. The next winner adds 300 times the honba count to their score!")
                }
                .padding(.init(top: 0, leading: 50, bottom: -10, trailing: 0))
                Spacer()
            }
            
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
                        }
                    })
                    if extraRounds {
                        Circle()
                            .stroke(AngularGradient(gradient: Gradient(colors: roundWind == "西" ? [.yellow, .purple] : [.mint, .yellow]), center: .center), style: StrokeStyle(
                                lineWidth: 15,
                                lineCap: .round
                            )).opacity(0.5)
                            .rotationEffect(.degrees(-90))
                            .frame(width: 120, height: 120)
                        Circle()
                            .trim(from: 0, to: (hiddenTimerTime + 1)/(maxTime + 1))
                            .stroke(AngularGradient(gradient: Gradient(colors: roundWind == "西" ? [.yellow, .purple] : [.mint, .yellow]), center: .center), style: StrokeStyle(
                                lineWidth: 15,
                                lineCap: .round
                            ))
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut, value: hiddenTimerTime/maxTime)
                            .frame(width: 120, height: 120)
                    } else {
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
                        .onTapGesture {
                            showDice = false
                        }
                    HStack {
                        Image(systemName: dieRoll1)
                        Image(systemName: dieRoll2)
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 100))
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
                            addingFu = 20
                            fu = 20
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
                            if calculateFu {
                                VStack {
                                    Text("Fu:")
                                    Picker("Fu", selection: $fu) {
                                        ForEach([20, 25, 30, 40, 50, 60, 70, 80, 90, 100, 110], id: \.self) { value in
                                            Text("\(value)")
                                                .foregroundColor(han >= 5 ? .gray : .primary)
                                                .tag(value)
                                        }
                                    }
                                    .disabled(han >= 5)
                                    .padding(.top, -20)
                                    .pickerStyle(.wheel)
                                }
                                .foregroundStyle(han > 4 ? .gray : .black)
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
                            addingFu = 20
                            fu = 20
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
                            if calculateFu {
                                VStack {
                                    Text("Fu:")
                                    Picker("Fu", selection: $fu) {
                                        ForEach([20, 25, 30, 40, 50, 60, 70, 80, 90, 100, 110], id: \.self) { value in
                                            Text("\(value)")
                                                .foregroundColor(han >= 5 ? .gray : .primary)
                                                .tag(value)
                                        }
                                    }
                                    .disabled(han >= 5)
                                    .padding(.top, -20)
                                    .pickerStyle(.wheel)
                                }
                                .foregroundStyle(han > 4 ? .gray : .black)
                            }
                        }
                    }
                    VStack {
                        Spacer()
                        Spacer()
                        Button {
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
            
            // overlaid fu button and display scoring
            if ron || tsumo {
                ShowFuButton(showFu: $showFu, timerOn: $timerOn, ron: $ron, tsumo: $tsumo, calculateFu: $calculateFu, han: $han)
                if !threePlayerMode {
                    Button("display scoring") {
                        displayScoring.toggle()
                    }
                    .foregroundStyle(.white)
                    .frame(width: 150, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(displayScoring ? Color.blue : Color.gray)
                    )
                    .offset(y: 300)
                }
            }
            
            if exhaust {
                ZStack {
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.6)
                        .onTapGesture {
                            exhaust = false
                        }
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
                        Button("submit") {
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
                        Button("quick 3") {
                            if (!editNames) {
                                threePlayerMode = true
                                displayScoring = false
                                quick3 = true
                                decideSeats()
                            }
                            enterNames = false
                            // showNames = true
                        }
                        .font(.system(size: 30))
                        .padding(.top, 210)
                        Spacer()
                    }
                    VStack {
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
                    .padding(.horizontal, 40)
                    VStack {
                        Spacer()
                        Button("submit") {
                            showNames = true
                            if (!editNames) {
                                decideSeats()
                            }
                            enterNames = false
                        }
                        .font(.system(size: 30))
                        .padding(.bottom, bottomPaddingForButtons)
                    }
                }.ignoresSafeArea()
            }
            
            if scoringScreen {
                ZStack {
                    Rectangle()
                        .ignoresSafeArea()
                        .foregroundColor(.black)
                        .opacity(0.8)
                    VStack {
                        Text("\(winner)の勝ち")
                            .font(.system(size: 50))
                            .padding()
                        
                        if wasTsumo {
                            if winner == "東" {
                                VStack {
                                    Text("Each player pays: ")
                                    Text("\(String(format: "%d", nonDealerPayment))")
                                }
                                .font(.largeTitle)
                                .padding()
                                Text("Han: \(han)\(han < 5 ? ", Fu: \(fu)" : "")")
                                if han < 5 {
                                    HStack(spacing: 2) {
                                        Text("Base points = \(String(format: "%d", fu)) fu * 2")
                                        Text("2 + \(String(format: "%d", han)) han")
                                            .font(.system(size: 12))
                                            .baselineOffset(8)
                                        Text(" = \(String(format: "%d", fu * Int(pow(2.0, Double(2 + han)))))")
                                    }
                                }
                            } else {
                                VStack {
                                    Text("東 pays:")
                                    Text("\(String(format: "%d", dealerPayment))")
                                }
                                .font(.largeTitle)
                                .padding()
                                VStack {
                                    Text("Han: \(han)\(han < 5 ? ", Fu: \(fu)" : "")")
                                    if han < 5 {
                                        HStack(spacing: 2) {
                                            Text("Base points = \(String(format: "%d", fu)) fu * 2")
                                            Text("2 + \(String(format: "%d", han)) han")
                                                .font(.system(size: 12))
                                                .baselineOffset(8)
                                            Text(" = \(String(format: "%d", fu * Int(pow(2.0, Double(2 + han)))))")
                                        }
                                    }
                                    Text("Dealer base point multiplier: 2")
                                    Text("\(String(format: "%d", basePoints)) * 2 = \(String(format: "%d", basePoints * 2))")
                                    Text("Rounded up to the nearest hundred: \(String(format: "%d", Int(ceil(Double(basePoints * 2) / 100.0) * 100.0)))")
                                    Text("Honba points: \(String(format: "%d", honbaCount)) * 100 = \(String(format: "%d", honbaCount * 100))")
                                    Text("Payout: \(String(format: "%d", Int(ceil(Double(basePoints * 2) / 100.0) * 100.0))) + \(String(format: "%d", honbaCount * 100)) = \(String(format: "%d", dealerPayment))")
                                }
                                VStack {
                                    Text("Non-dealers pay:")
                                    Text("\(String(format: "%d", nonDealerPayment))")
                                }
                                .font(.largeTitle)
                                .padding()
                            }
                            VStack {
                                if winner == "東" {
                                    Text("Base point multiplier: 2")
                                } else {
                                    Text("Non-dealer base point multiplier: 1")
                                }
                                if winner == "東" {
                                    
                                    Text("\(String(format: "%d", basePoints)) * 2 = \(String(format: "%d", basePoints * 2))")
                                    Text("Rounded up to the nearest hundred: \(String(format: "%d", Int(ceil(Double(basePoints * 2) / 100.0) * 100.0)))")
                                    Text("Honba points: \(String(format: "%d", honbaCount)) * 100 = \(String(format: "%d", honbaCount * 100))")
                                    Text("Payout: \(String(format: "%d", Int(ceil(Double(basePoints * 2) / 100.0) * 100.0))) + \(String(format: "%d", honbaCount * 100)) = \(String(format: "%d", nonDealerPayment))")
                                    
                                } else {
                                    Text("\(String(format: "%d", basePoints)) * 1 = \(String(format: "%d", basePoints * 1))")
                                    Text("Rounded up to the nearest hundred: \(String(format: "%d", Int(ceil(Double(basePoints * 1) / 100.0) * 100.0)))")
                                    Text("Non-dealer payout: \(String(format: "%d", Int(ceil(Double(basePoints * 1) / 100.0) * 100.0))) * 1 + \(String(format: "%d", honbaCount * 100)) = \(String(format: "%d", nonDealerPayment))")
                                }
                            }
                            VStack {
                                Text("Total winnings:")
                                if winner == "東" {
                                    Text("\(String(format: "%d", nonDealerPayment * 3 + riichiPot))")
                                } else {
                                    Text("\(String(format: "%d", dealerPayment + (nonDealerPayment * 2) + riichiPot))")
                                }
                            }
                            .padding()
                            .font(.largeTitle)
                            VStack {
                                if winner == "東" {
                                    Text("Payout: \(String(format: "%d", nonDealerPayment)) * 3 = \(String(format: "%d", nonDealerPayment * 3))")
                                } else {
                                    Text("Payout: \(String(format: "%d", dealerPayment)) + \(String(format: "%d", nonDealerPayment)) * 2 = \(String(format: "%d", dealerPayment + nonDealerPayment * 2))")
                                }
                                if riichiPot > 0 {
                                    Text("Riichi pot: \(String(format: "%d", riichiPot))")
                                    if winner == "東" {
                                        Text("\(String(format: "%d", nonDealerPayment * 3)) + \(String(format: "%d", riichiPot)) = \(String(format: "%d", nonDealerPayment * 3 + riichiPot))")
                                    } else {
                                        Text("\(String(format: "%d", dealerPayment + nonDealerPayment * 2)) + \(String(format: "%d", riichiPot)) = \(String(format: "%d", dealerPayment + nonDealerPayment * 2 + riichiPot))")
                                    }
                                }
                                
                            }
                        }
                        
                        if wasRon {
                            VStack {
                                Text("\(loser) pays:")
                                Text("\(String(format: "%d",winnerPoints))")
                            }
                            .font(.largeTitle)
                            .padding()
                            VStack {
                                Text("Han: \(han)\(han < 5 ? ", Fu: \(fu)" : "")")
                                if han < 5 {
                                    HStack(spacing: 2) {
                                        Text("Base points = \(fu) fu * 2")
                                        Text("2 + \(han) han")
                                            .font(.system(size: 12))
                                            .baselineOffset(8)
                                        Text(" = \(String(format: "%d", fu * Int(pow(2.0, Double(2 + han)))))")
                                    }
                                }
                                Text("Base point multiplier: \(multiplier) (\(winner == "東" ? "dealer" : "non-dealer"))")
                                Text("\(String(format: "%d", basePoints)) * \(multiplier) = \(String(format: "%d", basePoints * multiplier))")
                                Text("Rounded up the nearest hundred or minimum: \(String(format: "%d", winnerPoints - honbaCount * 300))")
                                Text("Honba points: \(honbaCount) * 300 = \(honbaCount * 300)")
                                Text("Payout: \(String(format: "%d", (winnerPoints - honbaCount * 300))) + \(honbaCount * 300) = \(String(format: "%d", winnerPoints))")
                            }
                            VStack {
                                Text("Total winnings:")
                                Text("\(String(format: "%d",winnerPoints + riichiPot))")
                            }
                            .padding()
                            .font(.largeTitle)
                            VStack {
                                Text("Payout: \(String(format: "%d", winnerPoints))")
                                Text("Riichi pot: \(String(format: "%d", riichiPot))")
                                Text("\(String(format: "%d", winnerPoints)) + \(String(format: "%d", riichiPot)) = \(String(format: "%d", winnerPoints + riichiPot))")
                                
                            }
                        }
                        
                        if winner == "東" {
                            Text("Honba increases by 1")
                                .font(.title2)
                                .padding()
                        }
                    }
                    .foregroundStyle(.white)
                    Color.clear
                            .contentShape(Rectangle()) // makes the whole rect tappable
                            .ignoresSafeArea()         // stretch to edges
                            .onTapGesture {
                                if wasTsumo {
                                    handleTsumoScoring()
                                }
                                if wasRon {
                                    handleRonScoring()
                                }
                            }
                }
            }
            
            if showNames {
                ZStack {
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.8)
                        .onTapGesture {
                            showNames = false
                        }
                    // up and left
                    if !threePlayerMode {
                        Button {
                            let temp = playerList[3].name
                            playerList[3].name = playerList[2].name
                            playerList[2].name = temp
                        } label: {
                            Image(systemName: "arrow.up.and.down")
                                .font(.system(size: 50))
                        }
                        .padding(10)
                        .contentShape(Rectangle())
                        .rotationEffect(.degrees(30))
                        .offset(x:-90, y: -240)
                    }
                    
                    // up and right
                    Button {
                        let temp = playerList[1].name
                        playerList[1].name = playerList[2].name
                        playerList[2].name = temp
                    } label: {
                        Image(systemName: "arrow.up.and.down")
                            .font(.system(size: 50))
                    }
                    .padding(10)
                    .contentShape(Rectangle())
                    .rotationEffect(.degrees(-30))
                    .offset(x:90, y: -240)
                    
                    // down and left
                    if !threePlayerMode {
                        Button {
                            let temp = playerList[3].name
                            playerList[3].name = playerList[0].name
                            playerList[0].name = temp
                        } label: {
                            Image(systemName: "arrow.up.and.down")
                                .font(.system(size: 50))
                        }
                        .padding(10)
                        .contentShape(Rectangle())
                        .rotationEffect(.degrees(-30))
                        .offset(x:-90, y: 240)
                    }
                    
                    // down and right
                    Button {
                        let temp = playerList[1].name
                        playerList[1].name = playerList[0].name
                        playerList[0].name = temp
                    } label: {
                        Image(systemName: "arrow.up.and.down")
                            .font(.system(size: 50))
                    }
                    .padding(10)
                    .contentShape(Rectangle())
                    .rotationEffect(.degrees(30))
                    .offset(x:90, y: 240)
                    
                    VStack {
                        // up and down
                        Button {
                            let temp = playerList[0].name
                            playerList[0].name = playerList[2].name
                            playerList[2].name = temp
                        } label: {
                            Image(systemName: "arrow.up.and.down")
                                .font(.system(size: 50))
                        }
                        .padding(10)
                        .contentShape(Rectangle())
                        
                        // left and right
                        if !threePlayerMode {
                            Button {
                                let temp = playerList[1].name
                                playerList[1].name = playerList[3].name
                                playerList[3].name = temp
                            } label: {
                                Image(systemName: "arrow.left.and.right")
                                    .font(.system(size: 50))
                            }
                            .padding(10)
                            .contentShape(Rectangle())
                        }
                    }
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
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            displayResultsScreen = false
                        }
                }.ignoresSafeArea()
            }
            
            if showYaku {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundStyle(.white)
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading) {
                            ForEach(yakuList) { yaku in
                                Text(yaku.han)
                                    .font(.title2)
                                    .padding(.top)
                                    .padding(.bottom)

                                ForEach(yaku.entries, id: \.self) { entry in
                                    Text(entry)
                                    Divider()
                                }
                            }
                        }
                        .frame(maxWidth: 370, alignment: .leading)
                    }
                    Button("done") {
                        showYaku = false
                    }
                }
            }
            
            if showFu {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundStyle(.white)
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading) {
                            Text("Fu (符)")
                                .font(.title2)
                            Text("Every winning hand starts with 20 fu")
                                .padding(.top)
                            Text("Closed Ron: +10")
                                .padding(.top)
                            Text("Tsumo: +2")
                                .padding(.top)
                            Text("Melds:")
                                .padding(.top)
                            BulletPoint(text: "Open triplet: +2 fu (+4 fu if terminals/honors)")
                            BulletPoint(text: "Closed triplet: +4 fu (+8 fu if terminals/honors)")
                            BulletPoint(text: "Open kan: +8 fu (+16 fu if terminals/honors)")
                            BulletPoint(text: "Closed kan: +16 fu (+32 fu if terminals/honors)")
                            Text("Waits:")
                                .padding(.top)
                            BulletPoint(text: "Open wait (両面): no extra fu")
                            BulletPoint(text: "Middle closed wait (嵌張): +2 fu")
                            BulletPoint(text: "Edge wait (辺張): +2 fu")
                            BulletPoint(text: "Pair wait (単騎): +2 fu")
                            Text("If your pair is a dragon, round wind, or seat wind: +2 fu")
                                .padding(.top)
                            Text("Seven pairs (七対子): +25 fu and that's all")
                                .padding(.top)
                            Text("Fu is rounded up to the nearest 10")
                                .padding(.top)
                            Text("Scoring: Base points = fu × 2^(2 + han)")
                                .padding(.top)
                            Text("Base points cap at 2000 and are fixed after a hand reaches or exceeds 5 han")
                                .padding(.top)
                            BulletPoint(text: "If non-dealer wins by ron: winner gets base × 4 (rounded up to nearest 100)")
                            BulletPoint(text: "If dealer wins by ron: winner gets base × 6 (rounded up to nearest 100)")
                            BulletPoint(text: "If non-dealer tsumo: dealer pays base × 2, other two pay base × 1")
                            BulletPoint(text: "If dealer tsumo: everyone pays base × 2")
                        }
                        .frame(maxWidth: 370, alignment: .leading)
                    }
                    if ron || tsumo {
                        HStack {
                            FuIncrementButton(addingFu: $addingFu, increment: 2)
                            FuIncrementButton(addingFu: $addingFu, increment: 4)
                            FuIncrementButton(addingFu: $addingFu, increment: 8)
                            FuIncrementButton(addingFu: $addingFu, increment: 10)
                            FuIncrementButton(addingFu: $addingFu, increment: 16)
                            FuIncrementButton(addingFu: $addingFu, increment: 32)
                        }
                    }
                    ZStack {
                        Button((addingFu == 20) ? "done" : "calculate") {
                            fu = Int(ceil(Double(addingFu) / 10.0) * 10.0)
                            showFu = false
                        }
                        .padding()
                        if ron || tsumo {
                            Text("Fu: \(addingFu)")
                                .offset(x: 130)
                        }
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
        if extraRounds {
            if roundWind == "西" {
                roundWind = "北"
            } else {
                roundWind = "西"
            }
        } else {
            if roundWind == "東" {
                roundWind = "南"
            } else {
                roundWind = "東"
            }
        }
    }
    
    func decideSeats() {
        // quick 3
        if quick3 {
            for i in playerList.indices {
                playerList[i].name = "player " + String(i + 1)
                playerList[i].score = 35000
            }
            playerList[3].score = -100000 // just to be sure it doesn't appear in the score list
            return
        }
        // quick start
        if enterPlayer1 == "" {
            print("enterPlayer1 was empty")
            for i in playerList.indices {
                playerList[i].name = "player " + String(i + 1)
            }
            showNames = false
            return
        }
        // names entered
        playerNamesShuffleList.append(enterPlayer1)
        playerNamesShuffleList.append(enterPlayer2)
        playerNamesShuffleList.append(enterPlayer3)
        playerNamesShuffleList.append(enterPlayer4)
        // on the off chance only one or two names were entered
        for i in playerNamesShuffleList.indices {
            if playerNamesShuffleList[i] == "" {
                playerNamesShuffleList[i] = "player" + String(i + 1)
            }
        }
        // fourth player left blank
        if playerNamesShuffleList[3] == "player4" {
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
        basePoints = calculateBasePoints()
        
        winnerPoints = 0
        dealerPayment = 0
        nonDealerPayment = 0
        
        tsumo = false
        wasTsumo = true
        
        if winner == "東" {
            // dealer doesn't pay
            // everyone pays base points * 2
            nonDealerPayment = Int(ceil(Double(basePoints * 2) / 100.0) * 100.0)
            if nonDealerPayment < 400 {
                nonDealerPayment = 400
            }
            nonDealerPayment += 100 * honbaCount
            winnerPoints = (threePlayerMode ? (nonDealerPayment * 2) : (nonDealerPayment * 3))
        } else {
            dealerPayment = Int(ceil(Double(basePoints * 2) / 100.0) * 100.0)
            if dealerPayment < 400 {
                dealerPayment = 400
            }
            dealerPayment += 100 * honbaCount
            nonDealerPayment = Int(ceil(Double(basePoints * 1) / 100.0) * 100.0)
            if nonDealerPayment < 200 {
                nonDealerPayment = 200
            }
            nonDealerPayment += 100 * honbaCount
            winnerPoints = threePlayerMode ? (dealerPayment + nonDealerPayment) : (dealerPayment + nonDealerPayment * 2)
        }
        print("tsumo winnerPoints = \(winnerPoints)")
        print("nonDealerPayment = \(nonDealerPayment)")
        print("dealerPayment = \(dealerPayment)")
        
        
        if !displayScoring {
            handleTsumoScoring()
        } else {
            scoringScreen = true
        }
    }
    
    func handleTsumoScoring() {
        scoringScreen = false
        
        downScoreChange = true
        upScoreChange = true
        if (!threePlayerMode) {
            leftScoreChange = true
        }
        rightScoreChange = true
        if winner == "東" {
            honbaCount += 1
        } else {
            honbaCount = 0
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
                
            } else {
                //handle the losers
                if playerList[i].wind == "東"{
                    switch i {
                    case 0: downLosingPoints = dealerPayment
                    case 1: rightLosingPoints = dealerPayment
                    case 2: upLosingPoints = dealerPayment
                    case 3: leftLosingPoints = dealerPayment
                    default: print("something went wrong")
                    }
                } else {
                    switch i {
                    case 0: downLosingPoints = nonDealerPayment
                    case 1: rightLosingPoints = nonDealerPayment
                    case 2: upLosingPoints = nonDealerPayment
                    case 3: leftLosingPoints = nonDealerPayment
                    default: print("something went wrong")
                    }
                }
            }
            playerList[i].riichi = false
            playerList[i].tenpai = false
        }
        wasTsumo = false
        riichiPot = 0
        riichiPotIndicator = 0
        han = 1
        fu = 20
        addingFu = 20
    }
    
    func scoreRon() {
        
        basePoints = calculateBasePoints()
        
        // Determine multiplier based on dealer status
        multiplier = (winner == "東") ? 6 : 4
        print("winner = \(winner), multiplier = \(multiplier)")
        winnerPoints = Int(ceil(Double(basePoints * multiplier) / 100.0) * 100.0)
        print("winnerPoints = \(winnerPoints)")
        
        // Apply minimum Ron points
        if winner == "東" {
            // Dealer minimum
            if winnerPoints < 1200 { winnerPoints = 1200 }
        } else {
            // Non-dealer minimum
            if winnerPoints < 1000 { winnerPoints = 1000 }
        }
        winnerPoints += 300 * honbaCount
        print("winnerPoints = \(winnerPoints)")
        ron = false
        wasRon = true
        if !displayScoring {
            handleRonScoring()
        } else {
            scoringScreen = true
        }
    }
    
    func handleRonScoring() {
        scoringScreen = false
        
        // Update winner
        for i in playerList.indices {
            if playerList[i].winner {
                switch i {
                case 0:
                    downScoreChange = true
                    downWinningPoints = winnerPoints + riichiPot
                case 1:
                    rightScoreChange = true
                    rightWinningPoints = winnerPoints + riichiPot
                case 2:
                    upScoreChange = true
                    upWinningPoints = winnerPoints + riichiPot
                case 3:
                    leftScoreChange = true
                    leftWinningPoints = winnerPoints + riichiPot
                default: break
                }
            }
            playerList[i].riichi = false
            playerList[i].tenpai = false
        }
        // handle loser
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
        if winner == "東" {
            honbaCount += 1
        } else {
            honbaCount = 0
        }
        riichiPot = 0
        riichiPotIndicator = 0
        han = 1
        fu = 20
        addingFu = 20
        wasRon = false
    }
    
    func calculateBasePoints() -> Int {
        print("calculating base points")
        if !calculateFu {
            fu = tsumo ? 30 : 20
        }
        if fu > 20 && fu < 30 && fu != 25 {
            fu = 30
        }
        print("tsumo: \(tsumo), fu: \(fu)")
        if tsumo && fu < 30 && fu != 25 {
            fu = 30
        }
        print("fu = \(fu)")
        
        basePoints = fu * Int(pow(2.0, Double(2 + han)))
        print("basePoints = \(basePoints)")
        if basePoints > 2000 {
            basePoints = 2000
            print("mangan cap, basePoints = \(basePoints)")
        }
        
        if han >= 5 {
            switch han {
            case 5: basePoints = 2000
            case 6...7: basePoints = 3000
            case 8...10: basePoints = 4000
            case 11...12: basePoints = 6000
            default: basePoints = 8000
            }
        }
        return basePoints
    }
    
    func scoreExhaust() {
        
        //count the tenpai
        for i in playerList.indices {
            if playerList[i].tenpai {
                tenpaiCounter += 1
            }
            playerList[i].riichi = false    //pot stays the same
        }
        if tenpaiCounter > 0 {
            honbaCount += 1
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
            riichiPotIndicator = riichiPot / 1000
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
        quick3 = false
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
        fu = 20
        addingFu = 20
        calculateFu = true
        winner = ""
        loser = ""
        roundWind = "東"
        timerOn = false
        timerTime = 24.0
        hiddenTimerTime = 24.0
        decimalSeconds = 10
        maxTime = 24.0
        playerTimer.upstream.connect().cancel()
        displayScoring = false
        honbaCount = 0
        extraRounds = false
        showTopKanji = false
        showBottomKanji = false
        showLeftKanji = false
        showRightKanji = false
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
        if windsList[1] == "東" {
            switch roundWind {
            case "東": roundWind = "南"
            case "南":
                extraRounds = true
                roundWind = "西"
            case "西": roundWind = "北"
            default:
                extraRounds = false
                roundWind = "東"
            }
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

struct BulletPoint: View {
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
                .multilineTextAlignment(.leading)
        }
        .padding(5)
    }
}

class AudioManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?

    func playSound() {
        // Configure AVAudioSession to allow background music to continue
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }

        // Load and play the sound
        guard let soundURL = Bundle.main.url(forResource: "act_rich", withExtension: "mp3") else {
            print("Error: MP3 file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
            print("Playing sound effect...")
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}

struct FuIncrementButton: View {
    @Binding var addingFu: Int   // bind to your state variable
    let increment: Int           // how much this button adds

    var body: some View {
        Button {
            if addingFu + increment <= 110 {
                addingFu += increment
            }
        } label: {
            Text("+\(increment)")
                .font(.system(size: 18, weight: .bold))
                .frame(width: 55)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

struct ShowFuButton: View {
    @Binding var showFu: Bool
    @Binding var timerOn: Bool
    @Binding var ron: Bool
    @Binding var tsumo: Bool
    @Binding var calculateFu: Bool
    @Binding var han: Int
    @State var justToggled = false
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    if !justToggled {
                        showFu = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill((ron || tsumo) ? Color.black : Color.clear)
                            .contentShape(Circle())
                            .frame(height: 40)
                        Text("符")
                            .font(.title2)
                            .foregroundStyle(
                                (!calculateFu || han >= 5)
                                ? Color.gray
                                : ((ron || tsumo) && calculateFu
                                   ? Color.cyan
                                   : Color.black)
                            )
                    }
                }
                .padding(.init(top: 0, leading: 0, bottom: -10, trailing: 30))
                .disabled(timerOn ? true : false)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            calculateFu.toggle()
                            justToggled = true
                            // small delay so it doesn't open the fu screen
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                justToggled = false
                            }
                        }
                )
                .sensoryFeedback(.success, trigger: calculateFu)
            }
            Spacer()
        }
    }
}

struct Yaku: Identifiable {
    let id = UUID()
    let han: String
    let entries: [String]
}

let yakuList: [Yaku] = [
    Yaku(han: "1 Han (Closed)", entries: [
        "門前自摸 (めんぜんつも) (Tsumo, Fully Concealed Hand) - self draw",
        "立直 (リーチ) (Riichi) - no pon or chii",
        "一発 (イッパツ) (Ippatsu) - win within first rotation after riichi, also can't be interrupted by tile calls",
        "平和 (ピンフ) (Pinfu) - all sequences and must end with a two-sided wait",
        "一盃口 (イーペイコー) (Pure Double Sequence) - 112233 kind of double sequence"
    ]),
    Yaku(han: "1 Han", entries: [
        "海底撈月 (ハイテイラオユエ) (Under the Sea) - Tsumo with the last drawn tile from the wall",
        "河底撈魚 (ホウテイラオユイ) (Under the River) - Ron with the last discarded tile",
        "嶺上開花 (リンシャンカイホウ) (After a Kan) - win with a tile drawn from the dead wall immediately after calling a Kan",
        "搶槓 (チャンカン) (Robbing a Kan) - calling Ron on another player's Kan (when you have a Tenpai for Thirteen Orphans, you can call on a Closed Kan)",
        "断幺九 (タンヤオ) (All Simples) - winning with no honor or terminal tiles (2-8 number tiles only)",
        "役牌 (やくはい) - a hand with at least one group of dragon, round wind, or seat wind tiles"
    ]),
    Yaku(han: "2 Han", entries: [
        "両立直 (ダブリー) (Double Riichi) - declare Riichi with your starting hand before any tiles are called",
        "全帯幺九 (チャンタ) (Half Outside Hand) - every sequence, triplet and pair contains at least one terminal tile or honor tiles (-1 Han if open)",
        "三色同順 (サンショクドウジュン) (Mixed Triple Sequence) - three sequences with the same numbers across the three suits (-1 Han if open)",
        "一気通貫 (イッキツウカン) (Pure Straight) - complete sequence 1–9 (-1 Han if open)",
        "対々 (トイトイ) (All Triplets) - all triplets (or quads), no sequences",
        "三暗刻 (サンアンコウ) (Three Concealed Triplets) - three sets of triplets (or quads) that were formed without calling any tiles",
        "三色同刻 (サンショクドウコウ) (Triple Triplets) - three triplets with the same number in each suit",
        "三槓子 (サンカンツ) (Three Kans) - three Kans, may be open",
        "七対子 (チートイツ) (Seven Pairs) - seven pairs, closed only",
        "混老頭 (ホンロウトウ) (All Terminals and Honors) - nothing but terminals and honors (usually scored with Seven Pairs or All Triplets)",
        "小三元 (ショウサンゲン) (Little Three Dragons) - two triplets of dragon tiles plus a pair of the third"
    ]),
    Yaku(han: "3 Han", entries: [
        "混一色 (ホンイーソー) (Half Flush) - single suit with honor tiles (-1 Han if open)",
        "純全帯么 (ジュンチャン) (Fully Outside Hand) - all sets contain at least one terminal tile (-1 Han if open)",
        "二盃口 (リャンペイコー) (Twice Pure Double Sequence) - two sets of Pure Double Sequence in two different suits (doesn't combine with Seven Pairs, closed only)"
    ]),
    Yaku(han: "6 Han", entries: [
        "清一色 (チンイーソー) (Full Flush) - one suit of number tiles (-1 Han if open)"
    ]),
    Yaku(han: "Mangan", entries: [
        "流し満貫 (ナガシマンガン) (Mangan at Draw) - all your discards were terminals/honors and no one called them (5 Han)"
    ]),
    Yaku(han: "Yakuman", entries: [
        "数え役満 (かぞえやくまん) - if your hand adds up to 13+ Han",
        "国士無双 (コクシムソウ) (Thirteen Orphans) - 1 & 9 of each suit, all winds, all dragons, plus one extra of any",
        "四暗刻 (スーアンコウ) (Four Concealed Triplets) - four closed triplets (closed only, you can only call the last tile for the pair)",
        "大三元 (ダイサンゲン) (Big Three Dragons) - three triplets of all three dragons",
        "小四喜 (ショウスーシー) (Little Four Winds) - three triplets/quads of winds plus a pair of the fourth",
        "大四喜 (ダイスーシー) (Big Four Winds) - four triplets/quads of all four winds",
        "字一色 (ツーイーソー) (All Honors) - nothing but honor tiles",
        "清老頭 (チンロウトウ) (All Terminals) - nothing but terminal tiles",
        "緑一色 (リューイーソー) (All Green) - only green tiles (23468 bamboo + green dragon)",
        "九連宝燈 (チューレンポートウ) (Nine Gates) - 1112345678999 + any one extra in the same suit (closed only)",
        "四槓子 (スーカンツ) (Four Quads) - four Kans, open or closed",
        "天和 (テンホー) (Blessing of Heaven) - dealer tsumo on the very first draw",
        "地和 (チーホー) (Blessing of Earth) - non-dealer tsumo on first draw before any calls"
    ])
]
