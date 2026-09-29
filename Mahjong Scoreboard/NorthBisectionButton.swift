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
    var body: some View {
        HStack {
            Spacer()
            Button {
                bisectNorth.toggle()
                    
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
        }
        Spacer()
    }
}

//#Preview {
//    NorthBisectionButton(bisectNorth: true, timerOn: false, ron: true, tsumo: false)
//}
