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

    private func randomRiichiSoundURL() -> URL? {
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
        // Configure AVAudioSession to allow background music to continue
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
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
            audioPlayer?.play()
            print("Playing sound effect...")
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}
