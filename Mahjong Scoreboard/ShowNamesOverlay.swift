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
        .background(PlayerNameAlert(
            isPresented: Binding(
                get: { editingPlayerIndex != nil },
                set: { if !$0 { editingPlayerIndex = nil } }
            ),
            name: nameDraft,
            onSave: { name in
                if let editingPlayerIndex {
                    playerList[editingPlayerIndex].name = name
                }
                editingPlayerIndex = nil
            },
            onCancel: {
                editingPlayerIndex = nil
            }
        ))
    }

    private func startRenamingPlayer(at index: Int) {
        nameDraft = playerList[index].name
        editingPlayerIndex = index
    }
}

struct PlayerNameAlert: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let name: String
    let onSave: (String) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ controller: UIViewController, context: Context) {
        guard isPresented, controller.view.window != nil, controller.presentedViewController == nil else { return }
        let alert = UIAlertController(title: "Change player name", message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Name"
            field.text = name
            field.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "save", style: .default) { [weak alert] _ in
            onSave(alert?.textFields?.first?.text ?? "")
        })
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel) { _ in
            onCancel()
        })
        controller.present(alert, animated: true) {
            guard let field = alert.textFields?.first else { return }
            field.becomeFirstResponder()
            field.selectedTextRange = field.textRange(from: field.beginningOfDocument, to: field.endOfDocument)
        }
    }
}
