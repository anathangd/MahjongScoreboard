import SwiftUI

struct RiichiHonbaIndicatorView: View {
    @Binding var showHonbaInfo: Bool
    let riichiPotIndicator: Int
    let honbaCount: Int
    let riichiPot: Int

    var body: some View {
        VStack {
            Button {
                showHonbaInfo = true
            } label: {
                HStack {
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
            .padding()
            Spacer()
        }
    }
}
