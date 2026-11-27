//
//  NorthBisectionButton.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 9/29/26.
//

import SwiftUI

struct NorthBisectionButton: View {
    @Binding var bisectNorth: Bool
    @Binding var ron: Bool
    @Binding var tsumo: Bool
    @State private var showStatus = false
    @State private var statusID = 0
    @State private var showExplanation = false

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Button {
                    bisectNorth.toggle()
                    statusID += 1
                    withAnimation(.easeIn(duration: 0.15)) {
                        showStatus = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill((ron || tsumo) ? Color.black : Color.clear)
                            .contentShape(Circle())
                            .frame(height: 40)
                        Text("北")
                            .font(.title2)
                            .foregroundStyle(
                                ((ron || tsumo) && bisectNorth
                                   ? Color.cyan
                                   : Color.gray)
                            )
                    }
                }
                .accessibilityLabel("Bisect North")
                .accessibilityValue(bisectNorth ? "On" : "Off")
                .sensoryFeedback(.success, trigger: bisectNorth)

                if showStatus {
                    Button {
                        showExplanation = true
                    } label: {
                        Text(bisectNorth ? "North bisection on" : "North bisection off")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .fixedSize()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Show North bisection explanation")
                    .transition(.opacity)
                }
            }
            .task(id: statusID) {
                guard showStatus else { return }
                do {
                    try await Task.sleep(for: .seconds(1.5))
                } catch {
                    return
                }
                withAnimation(.easeOut(duration: 0.35)) {
                    showStatus = false
                }
            }
            .alert("", isPresented: $showExplanation) {
                Button("Ah, okay", role: .cancel) { }
            } message: {
                Text("North bisection (北家折半)\n\nIn three-player mahjong, the missing North player's tsumo payment is split equally (and rounded up to the nearest 100) between the two remaining opponents, preventing tsumo loss.")
            }
        }
        Spacer()
    }
}

//#Preview {
//    NorthBisectionButton(bisectNorth: true, timerOn: false, ron: true, tsumo: false)
//}
