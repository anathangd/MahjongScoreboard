import SwiftUI

struct ShowFuOverlay: View {
    @Binding var showFu: Bool
    @Binding var fu: Int
    @Binding var addingFu: Int
    let showScoringControls: Bool

    var body: some View {
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
