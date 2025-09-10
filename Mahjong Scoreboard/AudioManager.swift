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

    func playSound() {
        // Configure AVAudioSession to allow background music to continue
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }

        // Load and play the sound
        guard let soundURL = Bundle.main.url(forResource: "act_rich", withExtension: "mp3") else {
            print("Error: MP3 file not found")
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
