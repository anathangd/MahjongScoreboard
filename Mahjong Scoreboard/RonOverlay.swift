import SwiftUI

struct RonOverlay: View {
    @Binding var playerList: [Player]
    @Binding var loser: String
    let ronList: [String]
    @Binding var han: Int
    @Binding var fu: Int
    let calculateFu: Bool
    let onSubmit: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.6)
                .onTapGesture {
                    onCancel()
                }

            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                    .cornerRadius(15)
                    .padding(.horizontal, 5)
                HStack(spacing: -10) {
                    VStack {
                        Text("Loser:")
                        Picker("", selection: $loser) {
                            ForEach(ronList, id: \.self) { wind in
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
                            Text("ダブル役満").tag(26)
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
                    onSubmit()
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
        }
        .ignoresSafeArea()
    }
}
