//
//  AudioManager.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 9/9/25.
//

import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?

    private let supportedAudioExtensions = ["m4a", "mp3", "wav"]
    private let riichiSoundNames = ["riichi1", "riichi2", "riichi3Patrick", "riichi4Patrick"]

    private func randomRiichiSoundURL() -> URL? {
        let explicitMatch = riichiSoundNames.compactMap { name in
            Bundle.main.url(
                forResource: name,
                withExtension: "m4a",
                subdirectory: "Riichi Sounds"
            )
        }.randomElement()

        if let explicitMatch {
            return explicitMatch
        }

        let matchingURLs = supportedAudioExtensions.flatMap { fileExtension in
            Bundle.main.urls(forResourcesWithExtension: fileExtension, subdirectory: nil) ?? []
        }
        .filter { url in
            url.deletingPathExtension().lastPathComponent.lowercased().hasPrefix("riichi")
        }

        if let randomURL = matchingURLs.randomElement() {
            return randomURL
        }

        return Bundle.main.url(forResource: "riichi", withExtension: "m4a")
    }

    func playSound() {
        // Playback ensures sound is audible even when the device is in silent mode.
        // mixWithOthers avoids interrupting currently playing audio.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }

        // Load and play the sound
        guard let soundURL = randomRiichiSoundURL() else {
            print("Error: no riichi audio files found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("Playing sound effect from: \(soundURL.lastPathComponent)")
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}
