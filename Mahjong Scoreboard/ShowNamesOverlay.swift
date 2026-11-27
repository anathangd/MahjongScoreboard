import SwiftUI

struct ShowNamesOverlay: View {
    @Binding var playerList: [Player]
    @Binding var showNames: Bool
    let threePlayerMode: Bool

    @State private var editingPlayerIndex: Int?
    @State private var nameDraft = ""

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.8)
                .onTapGesture {
                    showNames = false
                }

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
                .offset(x: -90, y: -240)
            }

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
            .offset(x: 90, y: -240)

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
                .offset(x: -90, y: 240)
            }

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
            .offset(x: 90, y: 240)

            VStack {
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
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: 400, height: 30)
                    .padding(.init(top: 0, leading: 0, bottom: 70, trailing: 0))
                    .rotationEffect(.degrees(180))
                    .onLongPressGesture {
                        startRenamingPlayer(at: 2)
                    }
                Spacer()
                Text(playerList[0].name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: 400, height: 30)
                    .padding(.init(top: 0, leading: 0, bottom: 50, trailing: 0))
                    .onLongPressGesture {
                        startRenamingPlayer(at: 0)
                    }
            }
            .font(.system(size: 60))
            .foregroundColor(.white)

            HStack {
                Text(playerList[3].name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: 400, height: 30)
                    .padding(.init(top: 230, leading: 0, bottom: 0, trailing: 0))
                    .rotationEffect(.degrees(90))
                    .onLongPressGesture {
                        startRenamingPlayer(at: 3)
                    }
                    .opacity(threePlayerMode ? 0 : 1)
                Spacer()
            }
            .font(.system(size: 60))
            .foregroundColor(.white)
            .padding(.horizontal, 10)

            HStack {
                Spacer()
                Text(playerList[1].name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: 400, height: 30)
                    .padding(.init(top: 230, leading: 0, bottom: 0, trailing: 0))
                    .rotationEffect(.degrees(-90))
                    .onLongPressGesture {
                        startRenamingPlayer(at: 1)
                    }
            }
            .font(.system(size: 60))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
        }
        .ignoresSafeArea()
        .alert(
            "Change player name",
            isPresented: Binding(
                get: { editingPlayerIndex != nil },
                set: { if !$0 { editingPlayerIndex = nil } }
            )
        ) {
            TextField("Name", text: $nameDraft)
            Button("save") {
                if let editingPlayerIndex {
                    playerList[editingPlayerIndex].name = nameDraft
                }
                editingPlayerIndex = nil
            }
            Button("cancel", role: .cancel) {
                editingPlayerIndex = nil
            }
        }
    }

    private func startRenamingPlayer(at index: Int) {
        nameDraft = playerList[index].name
        editingPlayerIndex = index
    }
}
