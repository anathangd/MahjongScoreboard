import SwiftUI

struct ExhaustOverlay: View {
    @Binding var playerList: [Player]
    @Binding var exhaust: Bool
    let threePlayerMode: Bool
    let bottomPaddingForButtons: CGFloat
    let onSubmit: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.6)
                .onTapGesture {
                    exhaust = false
                }

            VStack {
                TenpaiButton(player: playerList[2], tenpai: playerList[2].tenpai)
                    .rotationEffect(.degrees(180))
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
            .padding(80)

            HStack {
                TenpaiButton(player: playerList[3], tenpai: playerList[3].tenpai)
                    .rotationEffect(.degrees(90))
                    .onTapGesture {
                        if !playerList[3].riichi {
                            playerList[3].tenpai.toggle()
                        }
                    }
                    .opacity(threePlayerMode ? 0 : 1)
                    .allowsHitTesting(!threePlayerMode)
                Spacer()
                TenpaiButton(player: playerList[1], tenpai: playerList[1].tenpai)
                    .rotationEffect(.degrees(-90))
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
                    onSubmit()
                }
                .font(.system(size: 30))
                .padding(.bottom, bottomPaddingForButtons)
            }
        }
        .ignoresSafeArea()
    }
}
