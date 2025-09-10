//
//  ShowFuButton.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 9/9/25.
//

import SwiftUI

struct ShowFuButton: View {
    @Binding var showFu: Bool
    @Binding var timerOn: Bool
    @Binding var ron: Bool
    @Binding var tsumo: Bool
    @Binding var calculateFu: Bool
    @Binding var han: Int
    @State var justToggled = false
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    if !justToggled {
                        showFu = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill((ron || tsumo) ? Color.black : Color.clear)
                            .contentShape(Circle())
                            .frame(height: 40)
                        Text("符")
                            .font(.title2)
                            .foregroundStyle(
                                (!calculateFu || han >= 5)
                                ? Color.gray
                                : ((ron || tsumo) && calculateFu
                                   ? Color.cyan
                                   : Color.black)
                            )
                    }
                }
                .padding(.init(top: 0, leading: 0, bottom: -10, trailing: 30))
                .disabled(timerOn ? true : false)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            calculateFu.toggle()
                            justToggled = true
                            // small delay so it doesn't open the fu screen
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                justToggled = false
                            }
                        }
                )
                .sensoryFeedback(.success, trigger: calculateFu)
            }
            Spacer()
        }
    }
}

//#Preview {
//    ShowFuButton()
//}

struct FuIncrementButton: View {
    @Binding var addingFu: Int   // bind to your state variable
    let increment: Int           // how much this button adds

    var body: some View {
        Button {
            if addingFu + increment <= 110 {
                addingFu += increment
            }
        } label: {
            Text("+\(increment)")
                .font(.system(size: 18, weight: .bold))
                .frame(width: 55)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

struct BulletPoint: View {
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
                .multilineTextAlignment(.leading)
        }
        .padding(5)
    }
}
