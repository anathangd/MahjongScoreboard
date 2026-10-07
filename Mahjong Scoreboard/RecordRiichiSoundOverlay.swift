//
//  RecordRiichiSoundOverlay.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 10/7/26.
//

import SwiftUI

/// Records a custom riichi sound (max two seconds), lets the user boost the
/// volume and trim the ends, then saves it into the sound pool.
/// `onDismiss` runs when the overlay closes for any reason; `onSaved` runs
/// only when a recording was successfully saved.
struct RecordRiichiSoundOverlay: View {
    @StateObject private var recorder = RiichiSoundRecorder()
    let onDismiss: () -> Void
    var onSaved: () -> Void = {}

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Text("Record riichi sound")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
                    .padding(.top, 50)

                switch recorder.state {
                case .idle:
                    idleContent
                case .recording:
                    recordingContent
                case .readyToSave:
                    trimContent
                case .permissionDenied:
                    deniedContent
                }
            }
        }
        .onDisappear {
            recorder.discardRecording()
        }
    }

    // MARK: - idle

    private var idleContent: some View {
        VStack(spacing: 22) {
            Spacer()
            Button {
                recorder.startRecording()
            } label: {
                Image(systemName: "record.circle")
                    .font(.system(size: 100))
                    .foregroundStyle(.red)
            }
            Text("Tap to record\n(up to \(formatted(RiichiSoundRecorder.maxDuration)) seconds)")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            if let saveError = recorder.saveError {
                Text(saveError)
                    .font(.system(size: 15))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            Spacer()
            cancelButton
        }
    }

    // MARK: - recording

    private var recordingContent: some View {
        VStack(spacing: 22) {
            Spacer()
            Text("\(formatted(recorder.elapsed)) / \(formatted(RiichiSoundRecorder.maxDuration))")
                .font(.system(size: 44).monospacedDigit())
                .foregroundStyle(.white)
            Button {
                recorder.stopRecording()
            } label: {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.red)
            }
            Text("recording…")
                .foregroundStyle(.white)
            Spacer()
        }
    }

    // MARK: - trim

    private var trimContent: some View {
        VStack(spacing: 14) {
            Spacer()
            Text("Drag the ends to trim")
                .font(.system(size: 20))
                .foregroundStyle(.white)

            WaveformTrimView(
                samples: recorder.waveformSamples,
                duration: recorder.duration,
                trimStart: $recorder.trimStart,
                trimEnd: $recorder.trimEnd,
                isPlaying: recorder.isPreviewPlaying,
                playhead: recorder.previewTime,
                gain: recorder.gain
            )

            HStack {
                Text("start \(formatted(recorder.trimStart))s")
                Spacer()
                Text("length \(formatted(recorder.trimEnd - recorder.trimStart))s")
                Spacer()
                Text("end \(formatted(recorder.trimEnd))s")
            }
            .font(.system(size: 14))
            .foregroundStyle(.white.opacity(0.8))

            VStack(spacing: 4) {
                HStack {
                    Text("volume \(String(format: "%.1f", recorder.gain))×")
                        .foregroundStyle(.white)
                    if recorder.gain > 1 {
                        Text("red bars will distort")
                            .font(.system(size: 12))
                            .foregroundStyle(.red)
                    }
                }
                Slider(value: $recorder.gain, in: 1...4, step: 0.5)
                    .tint(.mint)
            }

            HStack(spacing: 30) {
                Button {
                    recorder.togglePreview()
                } label: {
                    Image(systemName: recorder.isPreviewPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(.white)
                }

                Button {
                    recorder.discardRecording()
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                }
            }
            .padding(.top, 6)

            if let saveError = recorder.saveError {
                Text(saveError)
                    .font(.system(size: 15))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }

            Spacer()

            Button("save") {
                recorder.saveRecording { success in
                    onDismiss()
                    if success {
                        onSaved()
                    }
                }
            }
            .font(.system(size: 30))
            .padding(.bottom, 6)

            cancelButton
        }
        .padding(.horizontal, 40)
    }

    // MARK: - permission denied

    private var deniedContent: some View {
        VStack(spacing: 22) {
            Spacer()
            Text("microphone access is off")
                .font(.system(size: 22))
                .foregroundStyle(.white)
            Text("turn it on in settings to record riichi sounds")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.75))
                .padding(.horizontal, 30)
            Button("open settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            .font(.system(size: 24))
            Spacer()
            cancelButton
        }
    }

    private var cancelButton: some View {
        Button("cancel") {
            onDismiss()
        }
        .font(.system(size: 26))
        .padding(.bottom, 40)
    }

    private func formatted(_ time: TimeInterval) -> String {
        String(format: "%.1f", time)
    }
}
