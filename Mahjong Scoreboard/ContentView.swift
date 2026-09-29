//
//  ContentView.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 9/8/23.
//

import SwiftUI
import AVFoundation
import Combine

struct ContentView: View {
     //player1 is in charge of the scoreboard
    @StateObject var audioManager = AudioManager()
    @State var timerUp: Publishers.Autoconnect<Timer.TimerPublisher>?
    @State var timerDown: Publishers.Autoconnect<Timer.TimerPublisher>?
    @State var timerLeft: Publishers.Autoconnect<Timer.TimerPublisher>?
    @State var timerRight: Publishers.Autoconnect<Timer.TimerPublisher>?
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
    @State var displayScoring = true
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
    
    @State private var multipleRon = false
    @State private var selectedLoser: String? = nil
    @State private var multipleRonScoringScreen = false
    @State private var multipleRonSummaryLines: [String] = []
    @State private var multipleRonTotalPaid = 0
    @State private var multipleRonLoserWind = ""
    @State private var multipleRonHonbaIncreases = false
    @State private var multipleRonWinnersTitle = ""
    
    @State private var bisectNorth: Bool = false
    
    let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    
    private var scoresAreChanging: Bool {
        downScoreChange || upScoreChange || leftScoreChange || rightScoreChange
    }

    var canSubmitMultipleRon: Bool {
        let winnerCount = playerList.filter { $0.multRonWin }.count
        let invalidCombo = playerList.contains { $0.multRonWin && $0.wind == selectedLoser }
        let validLoserSelected = ["東", "南", "西", "北"].contains(selectedLoser)
        return winnerCount >= 2 && !invalidCombo && validLoserSelected
    }
    
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
                    .padding()
                    .padding(.bottom, -20)
                    .disabled(timerOn ? true : false)
                }
            }
            
            //show fu and bisect north buttons
            VStack (spacing: 2) {
                ShowFuButton(showFu: $showFu, timerOn: $timerOn, ron: $ron, tsumo: $tsumo, calculateFu: $calculateFu, han: $han)
                Spacer()
            }
            
            
            //menu buttons
            GlassEffectContainer {
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
                            .padding(.init(top: 20, leading: 5, bottom: 25, trailing: 5))
                            .glassEffect(.identity)
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
            }
            
            //top and bottom players
            VStack(spacing: 0) {
                PlayerView(
                    player: $playerList[2],
                    isVertical: false,
                    timerOn: timerOn,
                    scoresAreChanging: scoresAreChanging,
                    playerDisabled: false,
                    menuActionsReversed: false,
                    showKanji: $showTopKanji,
                    winningPoints: $upWinningPoints,
                    losingPoints: $upLosingPoints,
                    scoreChangeActive: $upScoreChange,
                    loserWind: loser,
                    sleepDelay: sleepDelay,
                    onRon: {
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
                    },
                    onTsumo: {
                        tsumo = true
                        playerList[2].winner = true
                        winner = playerList[2].wind
                        playerList[0].loser = true
                        playerList[1].loser = true
                        playerList[3].loser = true
                    },
                    onMultipleRon: { multipleRon = true },
                    onToggleRiichi: { toggleRiichi(for: 2) }
                )
                .rotationEffect(.degrees(180))

                Spacer()

                PlayerView(
                    player: $playerList[0],
                    isVertical: false,
                    timerOn: timerOn,
                    scoresAreChanging: scoresAreChanging,
                    playerDisabled: false,
                    menuActionsReversed: true,
                    showKanji: $showBottomKanji,
                    winningPoints: $downWinningPoints,
                    losingPoints: $downLosingPoints,
                    scoreChangeActive: $downScoreChange,
                    loserWind: loser,
                    sleepDelay: sleepDelay,
                    onRon: {
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
                    },
                    onTsumo: {
                        tsumo = true
                        playerList[0].winner = true
                        winner = playerList[0].wind
                        playerList[1].loser = true
                        playerList[2].loser = true
                        playerList[3].loser = true
                    },
                    onMultipleRon: { multipleRon = true },
                    onToggleRiichi: { toggleRiichi(for: 0) }
                )
            }
            
            //left and right players
            HStack(spacing: 0) {
                PlayerView(
                    player: $playerList[3],
                    isVertical: true,
                    timerOn: timerOn,
                    scoresAreChanging: scoresAreChanging,
                    playerDisabled: threePlayerMode,
                    menuActionsReversed: false,
                    showKanji: $showLeftKanji,
                    winningPoints: $leftWinningPoints,
                    losingPoints: $leftLosingPoints,
                    scoreChangeActive: $leftScoreChange,
                    loserWind: loser,
                    sleepDelay: sleepDelay,
                    onRon: {
                        ron = true
                        playerList[3].winner = true
                        winner = playerList[3].wind
                        ronList.removeAll()
                        loser = playerList[0].wind
                        ronList.append(playerList[0].wind)
                        ronList.append(playerList[1].wind)
                        ronList.append(playerList[2].wind)
                    },
                    onTsumo: {
                        tsumo = true
                        playerList[3].winner = true
                        winner = playerList[3].wind
                        playerList[0].loser = true
                        playerList[1].loser = true
                        playerList[2].loser = true
                    },
                    onMultipleRon: { multipleRon = true },
                    onToggleRiichi: { toggleRiichi(for: 3) }
                )
                .frame(width: 300, height: 60)
                .rotationEffect(.degrees(90))
                .frame(width: 60, height: 300)
                .padding(40)

                Spacer()

                PlayerView(
                    player: $playerList[1],
                    isVertical: true,
                    timerOn: timerOn,
                    scoresAreChanging: scoresAreChanging,
                    playerDisabled: false,
                    menuActionsReversed: true,
                    showKanji: $showRightKanji,
                    winningPoints: $rightWinningPoints,
                    losingPoints: $rightLosingPoints,
                    scoreChangeActive: $rightScoreChange,
                    loserWind: loser,
                    sleepDelay: sleepDelay,
                    onRon: {
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
                    },
                    onTsumo: {
                        tsumo = true
                        playerList[1].winner = true
                        winner = playerList[1].wind
                        playerList[0].loser = true
                        playerList[2].loser = true
                        playerList[3].loser = true
                    },
                    onMultipleRon: { multipleRon = true },
                    onToggleRiichi: { toggleRiichi(for: 1) }
                )
                .frame(width: 300, height: 60)
                .rotationEffect(.degrees(-90))
                .frame(width: 60, height: 300)
                .padding(40)
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
                                .padding(.init(top: -5, leading: 0, bottom: -30, trailing: -5))
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
                                .padding(.init(top: -5, leading: 0, bottom: -30, trailing: -5))
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
            
            // riichi pot and honba indicator
            RiichiHonbaIndicatorView(
                showHonbaInfo: $showHonbaInfo,
                riichiPotIndicator: riichiPotIndicator,
                honbaCount: honbaCount,
                riichiPot: riichiPot,
                threePlayerMode: threePlayerMode
            )
            
            if timerOn {
                TimerOverlay(
                    timerOn: $timerOn,
                    playerTimer: $playerTimer,
                    timerTime: $timerTime,
                    hiddenTimerTime: $hiddenTimerTime,
                    decimalSeconds: $decimalSeconds,
                    maxTime: maxTime,
                    extraRounds: extraRounds,
                    roundWind: roundWind
                )
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
                RonOverlay(
                    playerList: $playerList,
                    loser: $loser,
                    ronList: ronList,
                    han: $han,
                    fu: $fu,
                    calculateFu: calculateFu,
                    onSubmit: {
                        scoreRon()
                    },
                    onCancel: {
                        ron = false
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
                )
            }
            
            if tsumo {
                TsumoOverlay(
                    playerList: $playerList,
                    han: $han,
                    fu: $fu,
                    calculateFu: calculateFu,
                    onSubmit: {
                        scoreTsumo()
                    },
                    onCancel: {
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
                )
            }
            
            // overlaid fu button and display scoring
            if ron || tsumo {
                VStack (spacing: 2) {
                    ShowFuButton(showFu: $showFu, timerOn: $timerOn, ron: $ron, tsumo: $tsumo, calculateFu: $calculateFu, han: $han)
                    if threePlayerMode {
                        NorthBisectionButton(bisectNorth: $bisectNorth, ron: $ron, tsumo: $tsumo)
                    }
                    Spacer()
                }
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
            
            if exhaust {
                ExhaustOverlay(
                    playerList: $playerList,
                    exhaust: $exhaust,
                    threePlayerMode: threePlayerMode,
                    bottomPaddingForButtons: bottomPaddingForButtons,
                    onSubmit: {
                        scoreExhaust()
                    }
                )
            }
            
            if enterNames {
                EnterNamesOverlay(
                    enterPlayer1: $enterPlayer1,
                    enterPlayer2: $enterPlayer2,
                    enterPlayer3: $enterPlayer3,
                    enterPlayer4: $enterPlayer4,
                    threePlayerMode: threePlayerMode,
                    bottomPaddingForButtons: bottomPaddingForButtons,
                    onQuick3: {
                        if !editNames {
                            threePlayerMode = true
                            quick3 = true
                            decideSeats()
                        }
                        enterNames = false
                    },
                    onSubmit: {
                        showNames = true
                        if !editNames {
                            decideSeats()
                        }
                        enterNames = false
                    }
                )
            }
            
            if scoringScreen {
                ScoringDisplay(
                    winner: winner,
                    wasTsumo: wasTsumo,
                    wasRon: wasRon,
                    han: han,
                    fu: fu,
                    honbaCount: honbaCount,
                    basePoints: basePoints,
                    nonDealerPayment: nonDealerPayment,
                    riichiPot: riichiPot,
                    dealerPayment: dealerPayment,
                    loser: loser,
                    multiplier: multiplier,
                    winnerPoints: winnerPoints,
                    threePlayerMode: threePlayerMode,
                    bisectNorth: bisectNorth,
                    multipleRonTitle: nil,
                    multipleRonSummaryLines: [],
                    multipleRonTotalPaid: 0,
                    multipleRonHonbaIncreases: false,
                    onDismiss: {
                        if wasTsumo {
                            handleTsumoScoring()
                        }
                        if wasRon {
                            handleRonScoring()
                        }
                    }
                )
            }
            
            if showNames {
                ShowNamesOverlay(
                    playerList: $playerList,
                    showNames: $showNames,
                    editNames: $editNames,
                    enterNames: $enterNames,
                    threePlayerMode: threePlayerMode
                )
            }
            
            if multipleRon {
                MultipleRonOverlay(
                    playerList: $playerList,
                    selectedLoser: $selectedLoser,
                    threePlayerMode: threePlayerMode,
                    canSubmitMultipleRon: canSubmitMultipleRon,
                    onSubmit: {
                        multipleRon = false
                        if displayScoring, let breakdown = calculateMultipleRonBreakdown() {
                            multipleRonLoserWind = breakdown.loserWind
                            multipleRonTotalPaid = breakdown.totalLoss
                            multipleRonHonbaIncreases = breakdown.honbaCountWillIncrease
                            multipleRonSummaryLines = breakdown.summaryLines
                            multipleRonWinnersTitle = breakdown.winnerTitle
                            multipleRonScoringScreen = true
                        } else {
                            handleMultipleRon()
                        }
                    },
                    onCancel: {
                        multipleRon = false
                        for i in playerList.indices {
                            playerList[i].multRonWin = false
                            playerList[i].loser = false
                        }
                        selectedLoser = nil
                    }
                )
            }

            if multipleRonScoringScreen {
                ScoringDisplay(
                    winner: "",
                    wasTsumo: false,
                    wasRon: false,
                    han: 0,
                    fu: 0,
                    honbaCount: honbaCount,
                    basePoints: 0,
                    nonDealerPayment: 0,
                    riichiPot: 0,
                    dealerPayment: 0,
                    loser: multipleRonLoserWind,
                    multiplier: 0,
                    winnerPoints: 0,
                    threePlayerMode: threePlayerMode,
                    bisectNorth: bisectNorth,
                    multipleRonTitle: multipleRonWinnersTitle,
                    multipleRonSummaryLines: multipleRonSummaryLines,
                    multipleRonTotalPaid: multipleRonTotalPaid,
                    multipleRonHonbaIncreases: multipleRonHonbaIncreases,
                    onDismiss: {
                        multipleRonScoringScreen = false
                        handleMultipleRon()
                    }
                )
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
                                    Text(.init(entry))
                                        .padding(.top, 5)
                                        .padding(.bottom, 5)
                                    if let example = YakuTileExample.example(for: entry) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(example.title)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text(example.groups.joined(separator: "  "))
                                                .foregroundStyle(example.isGreen ? Color(red: 0, green: 0.25, blue: 0) : Color.primary)
                                                .font(.system(size: 30))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.3)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.vertical, 4)
                                            .accessibilityElement(children: .ignore)
                                            .accessibilityLabel(example.accessibilityDescription)
                                        }
                                        .padding(.bottom, 8)
                                    }
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
                ShowFuOverlay(
                    showFu: $showFu,
                    fu: $fu,
                    addingFu: $addingFu,
                    showScoringControls: ron || tsumo
                )
            }
            
        }
        .onAppear {
            let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

            if !isPreview {
                timerDown = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                timerUp = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                timerLeft = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                timerRight = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
                playerTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            }
        }
        .onChange(of: downScoreChange) {
            finalizeScoringFlagsIfNeeded()
        }
        .onChange(of: upScoreChange) {
            finalizeScoringFlagsIfNeeded()
        }
        .onChange(of: leftScoreChange) {
            finalizeScoringFlagsIfNeeded()
        }
        .onChange(of: rightScoreChange) {
            finalizeScoringFlagsIfNeeded()
        }
    }

    func finalizeScoringFlagsIfNeeded() {
        if downScoreChange || upScoreChange || leftScoreChange || rightScoreChange {
            return
        }

        for i in playerList.indices {
            playerList[i].winner = false
            playerList[i].loser = false
        }

        winner = ""
        loser = ""
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
        }
    }
    
    func toggleRiichi(for index: Int) {
        if playerList[index].riichi {
            playerList[index].riichi = false
            playerList[index].tenpai = false
            playerList[index].score += 1000
            riichiPot -= 1000
            riichiPotIndicator = riichiPot / 1000
        } else {
            audioManager.playSound()
            playerList[index].riichi = true
            playerList[index].tenpai = true
            playerList[index].score -= 1000
            riichiPot += 1000
            riichiPotIndicator = riichiPot / 1000
        }
    }

    func scoreTsumo() {
        let breakdown = HandScoring.calculateTsumo(
            winnerWind: winner,
            han: han,
            fu: fu,
            honbaCount: honbaCount,
            threePlayerMode: threePlayerMode,
            bisectNorth: bisectNorth
        )

        basePoints = breakdown.basePoints
        winnerPoints = breakdown.winnerPoints
        dealerPayment = breakdown.dealerPayment
        nonDealerPayment = breakdown.nonDealerPayment

        tsumo = false
        wasTsumo = true

        if !displayScoring {
            handleTsumoScoring()
        } else {
            scoringScreen = true
        }
    }
    
    func handleTsumoScoring() {
        let plan = ScoreApplication.tsumo(
            players: playerList,
            winnerPoints: winnerPoints,
            dealerPayment: dealerPayment,
            nonDealerPayment: nonDealerPayment,
            riichiPot: riichiPot,
            honbaCount: honbaCount,
            threePlayerMode: threePlayerMode
        )
        applyScoreApplicationPlan(plan)
    }
    
    func scoreRon() {
        let breakdown = HandScoring.calculateRon(
            winnerWind: winner,
            han: han,
            fu: fu,
            honbaCount: honbaCount,
            threePlayerMode: threePlayerMode
        )

        basePoints = breakdown.basePoints
        multiplier = breakdown.multiplier
        winnerPoints = breakdown.winnerPoints

        ron = false
        wasRon = true
        if !displayScoring {
            handleRonScoring()
        } else {
            scoringScreen = true
        }
    }
    
    func handleRonScoring() {
        let plan = ScoreApplication.ron(
            players: playerList,
            winnerPoints: winnerPoints,
            riichiPot: riichiPot,
            winnerWind: winner,
            loserWind: loser,
            honbaCount: honbaCount
        )
        applyScoreApplicationPlan(plan)
    }
    
    func handleMultipleRon() {
        guard let breakdown = calculateMultipleRonBreakdown() else {
            return
        }
        let plan = ScoreApplication.multipleRon(
            players: playerList,
            breakdown: breakdown,
            honbaCount: honbaCount
        )
        applyScoreApplicationPlan(plan)
    }

    func calculateMultipleRonBreakdown() -> MultipleRonBreakdown? {
        MultipleRonScoring.calculateBreakdown(
            players: playerList,
            selectedLoser: selectedLoser,
            honbaCount: honbaCount,
            riichiPot: riichiPot,
            threePlayerMode: threePlayerMode
        )
    }

    func applyScoreApplicationPlan(_ plan: ScoreApplicationPlan) {
        showLeftKanji = false
        showRightKanji = false
        showTopKanji = false
        showBottomKanji = false
        scoringScreen = false

        playerList = plan.players

        downWinningPoints = plan.winningPointsByIndex[0]
        rightWinningPoints = plan.winningPointsByIndex[1]
        upWinningPoints = plan.winningPointsByIndex[2]
        leftWinningPoints = plan.winningPointsByIndex[3]

        downLosingPoints = plan.losingPointsByIndex[0]
        rightLosingPoints = plan.losingPointsByIndex[1]
        upLosingPoints = plan.losingPointsByIndex[2]
        leftLosingPoints = plan.losingPointsByIndex[3]

        downScoreChange = plan.scoreChangesByIndex[0]
        rightScoreChange = plan.scoreChangesByIndex[1]
        upScoreChange = plan.scoreChangesByIndex[2]
        leftScoreChange = plan.scoreChangesByIndex[3]

        honbaCount = plan.honbaCount
        riichiPot = plan.riichiPot
        riichiPotIndicator = plan.riichiPotIndicator
        han = plan.han
        fu = plan.fu
        addingFu = plan.addingFu
        wasRon = plan.wasRon
        wasTsumo = plan.wasTsumo

        if let selectedLoser = plan.selectedLoser {
            self.selectedLoser = selectedLoser
        }
    }
    
    func scoreExhaust() {
        //count the tenpai
        for i in playerList.indices {
            if threePlayerMode && i == 3 { continue }
            if playerList[i].tenpai {
                tenpaiCounter += 1
            }
        }

        let plan = ScoreApplication.exhaustiveDraw(
            players: playerList,
            tenpaiCount: tenpaiCounter,
            honbaCount: honbaCount,
            riichiPot: riichiPot,
            threePlayerMode: threePlayerMode,
            han: han,
            fu: fu,
            addingFu: addingFu
        )
        applyScoreApplicationPlan(plan)
        
        exhaust = false
        //reset variables
        tenpaiCounter = 0
        winnerPoints = 0
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
        riichiPot = 0
        riichiPotIndicator = 0
        han = 1
        fu = 20
        addingFu = 20
        calculateFu = true
        winner = ""
        loser = ""
        ron = false
        tsumo = false
        exhaust = false
        scoringScreen = false
        wasRon = false
        wasTsumo = false
        downScoreChange = false
        upScoreChange = false
        leftScoreChange = false
        rightScoreChange = false
        downWinningPoints = 0
        rightWinningPoints = 0
        upWinningPoints = 0
        leftWinningPoints = 0
        downLosingPoints = 0
        rightLosingPoints = 0
        upLosingPoints = 0
        leftLosingPoints = 0
        roundWind = "東"
        timerOn = false
        timerTime = 24.0
        hiddenTimerTime = 24.0
        decimalSeconds = 10
        maxTime = 24.0
        playerTimer.upstream.connect().cancel()
        displayScoring = true
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

struct RonWinnerButtonStyle: ButtonStyle {
    @Binding var isSelected: Bool
    
    init(isSelected: Binding<Bool>) {
        self._isSelected = isSelected
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .frame(width: 100, height: 60)
            .background(isSelected ? .blue : .gray)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .padding(10)
    }
}

struct RonLoserButtonStyle: ButtonStyle {
    @Binding var isSelected: Bool
    
    init(isSelected: Binding<Bool>) {
        self._isSelected = isSelected
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .frame(width: 50, height: 40)
            .background(isSelected ? .blue : .gray)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .padding(10)
    }
}

#Preview {
    ContentView()
}

struct HanFuPicker: View {
    @Binding var han: Int
    @Binding var fu: Int
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: 250, height: 120)
                .cornerRadius(15)
            HStack(spacing: 0) {
                VStack {
                    Text("Han:")
                        .font(.title3)
                    Picker("", selection: $han) {
                        ForEach(1...13, id: \.self) {
                            Text("\($0)")
                        }
                        Text("ダブル役満").tag(26)
                    }
                    .frame(width: 150, height: 100)
                    .clipped()
                    .padding(.top, -20)
                    .pickerStyle(.wheel)
                }
                VStack {
                    Text("Fu:")
                        .font(.title3)
                    Picker("Fu", selection: $fu) {
                        ForEach([20, 25, 30, 40, 50, 60, 70, 80, 90, 100, 110], id: \.self) { value in
                            Text("\(value)")
                                .foregroundColor(han >= 5 ? .gray : .primary)
                                .tag(value)
                        }
                    }
                    .frame(width: 70, height: 100)
                    .disabled(han >= 5)
                    .padding(.top, -20)
                    .pickerStyle(.wheel)
                }
                .foregroundStyle(han > 4 ? .gray : .black)
            }
        }
    }
}
