//
//  RiichiSoundsOverlay.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 10/7/26.
//

import SwiftUI
import AVFoundation
import UIKit

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
    @State private var showShareSheet = false
    @State private var importError: String?
    @State private var deletingSound: RiichiSound?

    private var hasRenameError: Binding<Bool> {
        Binding(
            get: { renameError != nil },
            set: { if !$0 { renameError = nil } }
        )
    }

    private var hasImportError: Binding<Bool> {
        Binding(
            get: { importError != nil },
            set: { if !$0 { importError = nil } }
        )
    }

    private var deleteConfirmationTitle: String {
        let name = deletingSound?.displayName ?? ""
        return "delete \(name)?"
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

                        Button {
                            stopPreview()
                            showShareSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 27))
                                .foregroundStyle(.white)
                        }
                        .accessibilityLabel("Share sounds nearby")
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

                List {
                    if store.customSounds.isEmpty {
                        Text("No custom sounds yet")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.6))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    ForEach(store.customSounds) { sound in
                        soundRow(sound)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    deletingSound = sound
                                } label: {
                                    Label("delete", systemImage: "trash")
                                }
                                .tint(.red)

                                Button {
                                    startRename(of: sound)
                                } label: {
                                    Label("edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }

                    if !store.customSounds.isEmpty {
                        Text("built in")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.5))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    ForEach(store.sounds.filter(\.isBundled)) { sound in
                        soundRow(sound)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)

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
        .alert("couldn't import", isPresented: hasImportError) {
            Button("ok", role: .cancel) {}
        } message: {
            Text(importError ?? "")
        }
        .confirmationDialog(
            deleteConfirmationTitle,
            isPresented: Binding(
                get: { deletingSound != nil },
                set: { if !$0 { deletingSound = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("delete", role: .destructive) {
                if let deletingSound {
                    deleteSound(deletingSound)
                }
                deletingSound = nil
            }
            Button("cancel", role: .cancel) {
                deletingSound = nil
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.audio]) { result in
            switch result {
            case .success(let url):
                do {
                    try store.importSound(from: url)
                } catch {
                    importError = error.localizedDescription
                }
            case .failure(let error):
                print("riichi sound import failed: \(error)")
            }
        }
        .sheet(isPresented: $showShareSheet) {
            NearbyRiichiShareView(store: store)
        }
    }

    private func soundRow(_ sound: RiichiSound) -> some View {
        let isEnabled = store.isEnabled(sound)

        return VStack(spacing: 0) {
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

                if sound.isBundled {
                    Button {
                        store.setEnabled(!isEnabled, for: sound)
                    } label: {
                        Image(systemName: isEnabled ? "checkmark.square.fill" : "square")
                            .font(.system(size: 24))
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(isEnabled ? "Disable \(sound.displayName)" : "Enable \(sound.displayName)")
                }
            }
            .buttonStyle(.borderless)
            .foregroundStyle(sound.isBundled && !isEnabled ? .white.opacity(0.4) : .white)
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

private struct NearbyRiichiShareView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var transfer: NearbyRiichiSoundTransfer
    private let soundCount: Int

    init(store: RiichiSoundStore) {
        _transfer = StateObject(wrappedValue: NearbyRiichiSoundTransfer(store: store))
        soundCount = store.customSounds.count
    }

    private var hasPendingInvitation: Binding<Bool> {
        Binding(
            get: { transfer.pendingInvitation != nil },
            set: { if !$0 { transfer.respondToInvitation(accept: false) } }
        )
    }

    private var hasLocalNetworkAccessIssue: Binding<Bool> {
        Binding(
            get: { transfer.localNetworkAccessIssue != nil },
            set: { if !$0 { transfer.dismissLocalNetworkAccessIssue() } }
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Nearby riichi sounds")
                    .font(.title2.weight(.semibold))

                Text(soundCount == 0 ? "No custom sounds to send" : "\(soundCount) custom sounds ready to share")
                    .foregroundStyle(.secondary)

                if transfer.discoveredPeers.isEmpty {
                    ContentUnavailableView(
                        "Looking for players",
                        systemImage: "dot.radiowaves.left.and.right",
                        description: Text("Keep both Share screens open and phones nearby. Wi-Fi and Bluetooth should be enabled.")
                    )
                } else {
                    List(transfer.discoveredPeers, id: \.self) { peer in
                        Button {
                            transfer.share(with: peer)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(peer.displayName)
                                        .foregroundStyle(.primary)
                                    Text("\(transfer.peerSoundCounts[peer, default: 0]) sounds available")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.forward.circle")
                            }
                        }
                        .disabled(soundCount == 0 || transfer.isTransferring)
                    }
                    .listStyle(.plain)
                }

                Text(transfer.status)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                DisclosureGroup("Connection details") {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(transfer.diagnostics.enumerated()), id: \.offset) { entry in
                                Text(entry.element)
                                    .font(.caption2.monospaced())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .frame(maxHeight: 140)
                }
                .font(.footnote)
                .padding(.horizontal)

                Spacer(minLength: 0)
            }
            .padding(.top)
            .navigationTitle("Share sounds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .disabled(transfer.isTransferring)
                }
            }
        }
        .task { transfer.start() }
        .onDisappear { transfer.stop() }
        .interactiveDismissDisabled(transfer.isTransferring)
        .alert(
            "Accept sound transfer?",
            isPresented: hasPendingInvitation
        ) {
            Button("Accept") {
                transfer.respondToInvitation(accept: true)
            }
            Button("Decline", role: .cancel) {
                transfer.respondToInvitation(accept: false)
            }
        } message: {
            Text("\(transfer.pendingInvitation?.displayName ?? "A nearby player") wants to send \(transfer.pendingInvitationSoundCount) sounds.")
        }
        .alert("Nearby access unavailable", isPresented: hasLocalNetworkAccessIssue) {
            Button("Open Settings") {
                transfer.dismissLocalNetworkAccessIssue()
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("OK", role: .cancel) {
                transfer.dismissLocalNetworkAccessIssue()
            }
        } message: {
            Text(transfer.localNetworkAccessIssue ?? "")
        }
    }
}
