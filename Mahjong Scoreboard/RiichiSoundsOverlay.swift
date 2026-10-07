//
//  RiichiSoundsOverlay.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 10/7/26.
//

import SwiftUI
import AVFoundation

/// Lists every riichi sound in the random pool — the bundled ones plus the
/// sounds the user imported or recorded. Bundled sounds can be previewed;
/// custom sounds can also be renamed and deleted.
struct RiichiSoundsOverlay: View {
    @ObservedObject var store: RiichiSoundStore
    let onDismiss: () -> Void
    let onRecord: () -> Void

    @State private var previewPlayer: AVAudioPlayer?
    @State private var playingURL: URL?
    @State private var renamingSound: RiichiSound?
    @State private var renameText = ""
    @State private var showRenameAlert = false
    @State private var renameError: String?
    @State private var showImporter = false

    private var hasRenameError: Binding<Bool> {
        Binding(
            get: { renameError != nil },
            set: { if !$0 { renameError = nil } }
        )
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Text("Riichi sounds")
                        .font(.system(size: 34))
                        .foregroundStyle(.white)
                        .padding(.top, 50)

                    HStack {
                        Button {
                            stopPreview()
                            showImporter = true
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                        }
                        .padding(.leading, 24)
                        .padding(.top, 50)

                        Spacer()

                        Button {
                            stopPreview()
                            onRecord()
                        } label: {
                            Image(systemName: "mic.circle")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 50)
                    }
                }

                Text("Custom sounds join the built-in ones\nin the random riichi pool")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.75))

                ScrollView {
                    VStack(spacing: 0) {
                        if store.customSounds.isEmpty {
                            Text("No custom sounds yet")
                                .font(.system(size: 18))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.vertical, 14)
                        }

                        ForEach(store.customSounds) { sound in
                            soundRow(sound)
                        }

                        if !store.customSounds.isEmpty {
                            Text("built in")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.5))
                                .padding(.top, 18)
                        }

                        ForEach(store.sounds.filter(\.isBundled)) { sound in
                            soundRow(sound)
                        }
                    }
                }

                Spacer()

                Button("done") {
                    stopPreview()
                    onDismiss()
                }
                .font(.system(size: 28))
                .padding(.bottom, 50)
            }
        }
        .alert("Rename sound", isPresented: $showRenameAlert) {
            TextField("Sound name", text: $renameText)
            Button("save") {
                commitRename()
            }
            .disabled(renameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Button("cancel", role: .cancel) {}
        }
        .alert("couldn't rename", isPresented: hasRenameError) {
            Button("ok", role: .cancel) {}
        } message: {
            Text(renameError ?? "")
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.audio]) { result in
            switch result {
            case .success(let url):
                do {
                    try store.importSound(from: url)
                } catch {
                    print("riichi sound import failed: \(error)")
                }
            case .failure(let error):
                print("riichi sound import failed: \(error)")
            }
        }
    }

    private func soundRow(_ sound: RiichiSound) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 18) {
                Button {
                    togglePreview(for: sound.url)
                } label: {
                    Image(systemName: playingURL == sound.url ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 32))
                }

                Text(sound.displayName)
                    .font(.system(size: 20))
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                if !sound.isBundled {
                    Button {
                        startRename(of: sound)
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 22))
                    }

                    Button {
                        deleteSound(sound)
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 22))
                    }
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)

            Divider()
                .background(Color.white.opacity(0.35))
                .padding(.horizontal, 20)
        }
    }

    private func togglePreview(for url: URL) {
        if playingURL == url {
            stopPreview()
            return
        }
        stopPreview()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            let player = try AVAudioPlayer(contentsOf: url)
            previewPlayer = player
            playingURL = url
            player.play()

            // Reset the icon once the sound finishes playing on its own.
            let scheduledPlayer = player
            Timer.scheduledTimer(withTimeInterval: player.duration, repeats: false) { _ in
                if playingURL == url && previewPlayer === scheduledPlayer {
                    stopPreview()
                }
            }
        } catch {
            print("couldn't preview sound: \(error)")
        }
    }

    private func stopPreview() {
        previewPlayer?.stop()
        previewPlayer = nil
        playingURL = nil
    }

    private func startRename(of sound: RiichiSound) {
        if playingURL == sound.url {
            stopPreview()
        }
        renameText = sound.name
        renamingSound = sound
        showRenameAlert = true
    }

    private func commitRename() {
        guard let sound = renamingSound else { return }
        do {
            try store.rename(sound.url, to: renameText)
            renamingSound = nil
        } catch {
            renameError = error.localizedDescription
        }
    }

    private func deleteSound(_ sound: RiichiSound) {
        if playingURL == sound.url {
            stopPreview()
        }
        store.delete(sound.url)
    }
}
