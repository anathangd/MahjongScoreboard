import SwiftUI

struct EnterNamesOverlay: View {
    @Binding var enterPlayer1: String
    @Binding var enterPlayer2: String
    @Binding var enterPlayer3: String
    @Binding var enterPlayer4: String
    let threePlayerMode: Bool
    let bottomPaddingForButtons: CGFloat
    let onQuick3: () -> Void
    let onSubmit: () -> Void

    private var submitTitle: String {
        enterPlayer1.isEmpty && enterPlayer2.isEmpty && enterPlayer3.isEmpty && enterPlayer4.isEmpty ? "quick 4" : "submit"
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.6)

            VStack {
                Button("quick 3") {
                    onQuick3()
                }
                .font(.system(size: 30))
                .padding(.top, 210)
                Spacer()
            }

            VStack {
                TextField(
                    "Enter player name",
                    text: $enterPlayer1
                )
                .textFieldStyle(.roundedBorder)

                TextField(
                    "Enter player name",
                    text: $enterPlayer2
                )
                .textFieldStyle(.roundedBorder)

                TextField(
                    "Enter player name",
                    text: $enterPlayer3
                )
                .textFieldStyle(.roundedBorder)

                TextField(
                    "Enter player name",
                    text: $enterPlayer4
                )
                .textFieldStyle(.roundedBorder)
                .opacity(threePlayerMode ? 0 : 1)
            }
            .font(.system(size: 30))
            .padding()

            VStack {
                Spacer()
                Button(submitTitle) {
                    onSubmit()
                }
                .font(.system(size: 30))
                .padding(.bottom, bottomPaddingForButtons)
            }
        }
        .ignoresSafeArea()
    }
}
