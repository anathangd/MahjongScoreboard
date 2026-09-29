import SwiftUI

struct ShowFuOverlay: View {
    @Binding var showFu: Bool
    @Binding var fu: Int
    @Binding var addingFu: Int
    let showScoringControls: Bool
    @State private var referenceIsDealer = false

    private var hanScoringReference: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Han (飜) scoring table")
                .font(.title2)
            Picker("Winner", selection: $referenceIsDealer) {
                Text("Non-dealer").tag(false)
                Text("Dealer (東)").tag(true)
            }
            .pickerStyle(.segmented)

            Text("Ron points • excludes honba and riichi sticks")
                .font(.caption)
                .foregroundStyle(.secondary)

            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    referenceCell("Fu")
                    ForEach(1...4, id: \.self) { han in
                        referenceCell("\(han) han")
                    }
                }
                .fontWeight(.semibold)
                ForEach([25, 30, 40, 50, 60, 70, 80, 90, 100, 110], id: \.self) { referenceFu in
                    GridRow {
                        referenceCell("\(referenceFu)")
                            .fontWeight(.semibold)
                        ForEach(1...4, id: \.self) { referenceHan in
                            if referenceFu == 25 && referenceHan == 1 {
                                referenceCell("—")
                            } else {
                                referenceCell("\(ronReferencePoints(han: referenceHan, fu: referenceFu))")
                            }
                        }
                    }
                }
            }
            .font(.caption)
            .monospacedDigit()
            .frame(maxWidth: .infinity)

            Text("20 fu applies to tsumo. Seven pairs uses 25 fu and is worth 2 han. Capped values below 5 han are mangan.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    referenceCell("Han")
                    referenceCell("Limit")
                    referenceCell("Ron points")
                }
                .fontWeight(.semibold)
                limitReferenceRow("5", name: "Mangan", han: 5)
                limitReferenceRow("6–7", name: "Haneman", han: 6)
                limitReferenceRow("8–10", name: "Baiman", han: 8)
                limitReferenceRow("11–12", name: "Sanbaiman", han: 11)
                limitReferenceRow("13–25", name: "Yakuman", han: 13)
                limitReferenceRow("26", name: "Double yakuman", han: 26)
            }
            .font(.caption)
            .monospacedDigit()
            Text("Limit values follow this app's scoring settings.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func referenceCell(_ text: String) -> some View {
        Text(text)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 44)
            .overlay {
                Rectangle()
                    .strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.5)
            }
    }

    private func ronReferencePoints(han: Int, fu: Int) -> Int {
        HandScoring.calculateRon(
            winnerWind: referenceIsDealer ? "東" : "南",
            han: han,
            fu: fu,
            honbaCount: 0
        ).winnerPoints
    }

    private func limitReferenceRow(_ label: String, name: String, han: Int) -> some View {
        GridRow {
            referenceCell(label)
            referenceCell(name)
            referenceCell("\(ronReferencePoints(han: han, fu: 30))")
        }
    }

    var body: some View {
        Rectangle()
            .ignoresSafeArea()
            .foregroundStyle(.white)
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("Fu (符)")
                        .font(.title2)
                    Text("Most hands start with 20 fu; see the exceptions below.")
                        .padding(.top)
                    Text("Closed Ron: +10 fu")
                        .padding(.top)
                    Text("Tsumo: +2 fu, except pinfu tsumo and seven pairs.")
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
                    Text("Seven pairs (七対子): exactly 25 fu. No additions or rounding.")
                        .padding(.top)
                    Text("Pinfu tsumo: exactly 20 fu. Do not add the usual +2 fu for tsumo.")
                        .padding(.top)
                    Text("An open hand won by ron that would otherwise total 20 fu is counted as 30 fu.")
                        .padding(.top)
                    Text("Round the total fu up to the nearest 10, except seven pairs, which stays at 25 fu.")
                        .padding(.top)
                    Text("Scoring:")
                        .font(.title2)
                        .padding(.top)
                    Text("Base points = fu × 2^(2 + han)")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                    Text("Below 5 han, use this formula with a maximum of 2,000 base points (mangan). At 5 han or more, use the limit-hand table below instead; fu no longer changes the score.")
                        .padding(.top)
                    BulletPoint(text: "If non-dealer wins by ron: winner gets base × 4 (rounded up to nearest 100)")
                    BulletPoint(text: "If dealer wins by ron: winner gets base × 6 (rounded up to nearest 100)")
                    Text("Four-player tsumo")
                        .font(.headline)
                        .padding(.top)
                    BulletPoint(text: "Non-dealer wins: dealer pays base × 2; the other two players each pay base × 1.")
                    BulletPoint(text: "Dealer wins: each of the three opponents pays base × 2.")
                    Text("Round each opponent's payment up separately to the nearest 100.")

                    Text("Three-player tsumo")
                        .font(.headline)
                        .padding(.top)
                    BulletPoint(text: "Normally, omit North's payment. Only the two active opponents pay.")
                    BulletPoint(text: "With Bisect North enabled, calculate North's rounded payment without honba, divide it in half, and round each half up to the nearest 100. Add that amount to each active opponent's payment.")

                    Text("Honba and riichi sticks")
                        .font(.headline)
                        .padding(.top)
                    Text("Add bonuses after calculating the hand's payments. For tsumo, each active opponent adds 100 points per honba: 300 total in four-player mode or 200 in three-player mode. North contributes no honba, even with bisection enabled.")
                    Text("The winner receives the opponents' payments plus the riichi pot. Riichi sticks are already in the pot; do not charge them to an opponent again.")
                        .padding(.top, 8)

                    Text("Example: non-dealer ron")
                        .font(.headline)
                        .padding(.top)
                    Text("3 han, 30 fu, before honba or riichi sticks:")
                    BulletPoint(text: "Base points: 30 × 2^(2 + 3) = 960")
                    BulletPoint(text: "Ron payment: 960 × 4 = 3,840")
                    BulletPoint(text: "Round up to the nearest 100: 3,900 points")
                    hanScoringReference
                        .padding(.top, 24)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            }
            if showScoringControls {
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
                if showScoringControls {
                    Text("Fu: \(addingFu)")
                        .offset(x: 130)
                }
            }
        }
    }
}
