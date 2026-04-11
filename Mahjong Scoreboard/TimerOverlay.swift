import SwiftUI
import Combine
import AudioToolbox

struct TimerOverlay: View {
    @Binding var timerOn: Bool
    @Binding var playerTimer: Publishers.Autoconnect<Timer.TimerPublisher>
    @Binding var timerTime: Double
    @Binding var hiddenTimerTime: Double
    @Binding var decimalSeconds: Int
    let maxTime: Double
    let extraRounds: Bool
    let roundWind: String

    var body: some View {
        ZStack {
            Circle()
                .frame(width: 135, height: 135)
                .foregroundStyle(.white)
            HStack {
                Text(String(format: "%.0f", timerTime))
                    .font(.system(size: timerTime > 9 ? 65 : 80))
                    .monospacedDigit()
                    .padding(.init(top: 0, leading: 10, bottom: 0, trailing: 0))
                Text(decimalSeconds == 10 ? ".0" : "." + String(decimalSeconds))
                    .monospacedDigit()
                    .padding(.init(top: 0, leading: -10, bottom: -20, trailing: 0))
            }
            .onAppear {
                hiddenTimerTime = maxTime
                timerTime = maxTime
                decimalSeconds = 9
                playerTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            .onReceive(playerTimer, perform: { _ in
                hiddenTimerTime -= 0.1
                decimalSeconds -= 1
                if decimalSeconds < 0 {
                    decimalSeconds = 9
                    timerTime -= 1
                }
                if hiddenTimerTime < 0 && decimalSeconds == 0 {
                    timerTime = 0
                    playerTimer.upstream.connect().cancel()
                    AudioServicesPlaySystemSound(1031)
                }
            })
            if extraRounds {
                Circle()
                    .stroke(AngularGradient(gradient: Gradient(colors: roundWind == "西" ? [.yellow, .purple] : [.mint, .yellow]), center: .center), style: StrokeStyle(
                        lineWidth: 15,
                        lineCap: .round
                    )).opacity(0.5)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: (hiddenTimerTime + 1) / (maxTime + 1))
                    .stroke(AngularGradient(gradient: Gradient(colors: roundWind == "西" ? [.yellow, .purple] : [.mint, .yellow]), center: .center), style: StrokeStyle(
                        lineWidth: 15,
                        lineCap: .round
                    ))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: hiddenTimerTime / maxTime)
                    .frame(width: 120, height: 120)
            } else {
                Circle()
                    .stroke(AngularGradient(gradient: Gradient(colors: roundWind == "東" ? [.red, .gray] : [.green, .yellow]), center: .center), style: StrokeStyle(
                        lineWidth: 15,
                        lineCap: .round
                    )).opacity(0.5)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: (hiddenTimerTime + 1) / (maxTime + 1))
                    .stroke(AngularGradient(gradient: Gradient(colors: roundWind == "東" ? [.red, .gray] : [.green, .yellow]), center: .center), style: StrokeStyle(
                        lineWidth: 15,
                        lineCap: .round
                    ))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: hiddenTimerTime / maxTime)
                    .frame(width: 120, height: 120)
            }
        }
        .frame(width: 150, height: 150)
        .onTapGesture {
            hiddenTimerTime = maxTime
            timerTime = maxTime
            decimalSeconds = 9
            playerTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        .onLongPressGesture {
            timerOn = false
        }
    }
}
