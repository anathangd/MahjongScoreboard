import SwiftUI

struct MultipleRonOverlay: View {
    @Binding var playerList: [Player]
    @Binding var selectedLoser: String?
    let threePlayerMode: Bool
    let canSubmitMultipleRon: Bool
    let onSubmit: () -> Void
    let onCancel: () -> Void

    private var selectablePlayerIndices: [Int] {
        playerList.indices.filter { !threePlayerMode || playerList[$0].wind != "北" }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .opacity(0.6)
                .onTapGesture {
                    onCancel()
                }

            VStack {
                VStack {
                    Text("Winners:")
                        .foregroundStyle(.white)
                        .padding(.bottom, -5)

                    ForEach(selectablePlayerIndices, id: \.self) { i in
                        HStack(spacing: 0) {
                            Button(playerList[i].wind) {
                                playerList[i].multRonWin.toggle()
                            }
                            .buttonStyle(RonWinnerButtonStyle(isSelected: $playerList[i].multRonWin))

                            if playerList[i].multRonWin {
                                HanFuPicker(han: $playerList[i].han, fu: $playerList[i].fu)
                            }
                        }
                    }

                    Text("Loser:")
                        .foregroundStyle(.white)
                }
                .font(.system(size: 50))

                HStack(spacing: 0) {
                    ForEach(selectablePlayerIndices, id: \.self) { i in
                        Button(playerList[i].wind) {
                            for j in playerList.indices {
                                playerList[j].loser = false
                            }
                            playerList[i].loser = true
                            selectedLoser = playerList[i].wind
                        }
                        .buttonStyle(RonLoserButtonStyle(isSelected: .constant(selectedLoser == playerList[i].wind)))
                    }
                }
                .font(.title)
                .padding(.top, threePlayerMode ? 0 : -20)
            }
            .padding(.top, -20)

            VStack {
                Spacer()
                Button("submit") {
                    onSubmit()
                }
                .disabled(!canSubmitMultipleRon)
                .font(.system(size: 30))
                .foregroundStyle(.white)
                .frame(width: 130, height: 60)
                .background(canSubmitMultipleRon ? .blue : .gray)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding()
            }
            .ignoresSafeArea()
        }
    }
}
