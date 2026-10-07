//
//  RiichiSoundStore.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 10/7/26.
//

import Foundation
import AVFoundation
import Combine

/// One riichi sound effect: either bundled with the app or added by the user.
struct RiichiSound: Identifiable, Equatable {
    let url: URL
    let isBundled: Bool

    var id: URL { url }
    var name: String { url.deletingPathExtension().lastPathComponent }
    var displayName: String { url.lastPathComponent }
}

/// Stores user-imported and user-recorded riichi sound effects.
/// Files live in Documents/RiichiSounds so they persist between launches,
/// and they join the bundled sounds in the random pool played on riichi.
class RiichiSoundStore: ObservableObject {
    static let shared = RiichiSoundStore()

    /// Every sound in the random riichi pool: bundled first, then custom ones.
    @Published private(set) var sounds: [RiichiSound] = []

    /// Just the sounds the user imported or recorded.
    var customSounds: [RiichiSound] {
        sounds.filter { !$0.isBundled }
    }

    static let supportedExtensions = ["m4a", "mp3", "wav", "aif", "aiff", "caf"]
    private static let bundledSoundNames = ["riichi1", "riichi2", "riichi3Patrick", "riichi4Patrick"]

    // Limits for imported sounds: these are short riichi calls, so huge files,
    // long clips, and unlimited piles of sounds don't make sense.
    static let maxImportFileSizeBytes: Int64 = 25 * 1024 * 1024
    static let maxImportDuration: TimeInterval = 10
    static let maxCustomSounds = 50

    private init() {
        refresh()
    }

    /// Directory where custom riichi sounds are stored.
    var soundsDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = documents.appendingPathComponent("RiichiSounds", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    /// Reloads the list of sounds from disk and the app bundle.
    func refresh() {
        let bundled = Self.bundledSoundNames.compactMap { name in
            Bundle.main.url(forResource: name, withExtension: "m4a", subdirectory: "Riichi Sounds")
                ?? Bundle.main.url(forResource: name, withExtension: "m4a")
        }

        let contents = (try? FileManager.default.contentsOfDirectory(
            at: soundsDirectory,
            includingPropertiesForKeys: nil
        )) ?? []

        let custom = contents
            .filter { Self.supportedExtensions.contains($0.pathExtension.lowercased()) }
            .sorted {
                $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending
            }

        sounds = bundled.map { RiichiSound(url: $0, isBundled: true) }
            + custom.map { RiichiSound(url: $0, isBundled: false) }
    }

    /// Copies an external audio file (from the document picker) into the sounds
    /// directory, after checking it against the import limits.
    func importSound(from sourceURL: URL) throws {
        let accessing = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        guard customSounds.count < Self.maxCustomSounds else {
            throw SoundImportError.tooManySounds
        }

        let attributes = try FileManager.default.attributesOfItem(atPath: sourceURL.path)
        let fileSize = (attributes[.size] as? NSNumber)?.int64Value ?? 0
        guard fileSize <= Self.maxImportFileSizeBytes else {
            throw SoundImportError.fileTooLarge
        }

        let audioFile = try AVAudioFile(forReading: sourceURL)
        let duration = Double(audioFile.length) / audioFile.processingFormat.sampleRate
        guard duration > 0 else {
            throw SoundImportError.unreadableFile
        }
        guard duration <= Self.maxImportDuration else {
            throw SoundImportError.tooLong
        }

        let destination = uniqueDestinationURL(for: sourceURL.lastPathComponent)
        try FileManager.default.copyItem(at: sourceURL, to: destination)
        refresh()
    }

    /// Deletes a custom sound from the sounds directory.
    func delete(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
        refresh()
    }

    /// Renames a custom sound, keeping its file extension.
    func rename(_ url: URL, to newBaseName: String) throws {
        let trimmed = newBaseName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        guard !trimmed.isEmpty, trimmed != url.deletingPathExtension().lastPathComponent else { return }

        let destination = url.deletingLastPathComponent()
            .appendingPathComponent(trimmed)
            .appendingPathExtension(url.pathExtension)

        guard !FileManager.default.fileExists(atPath: destination.path) else {
            throw SoundRenameError.nameTaken
        }

        try FileManager.default.moveItem(at: url, to: destination)
        refresh()
    }

    /// Returns a URL inside the sounds directory that does not collide with an existing file.
    func uniqueDestinationURL(for fileName: String) -> URL {
        let baseName = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
        let pathExtension = URL(fileURLWithPath: fileName).pathExtension
        var candidate = soundsDirectory.appendingPathComponent(fileName)
        var counter = 2
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = soundsDirectory.appendingPathComponent("\(baseName) \(counter).\(pathExtension)")
            counter += 1
        }
        return candidate
    }
}

enum SoundRenameError: LocalizedError {
    case nameTaken

    var errorDescription: String? {
        switch self {
        case .nameTaken: return "a sound with that name already exists"
        }
    }
}

enum SoundExportError: LocalizedError {
    case unreadableFile

    var errorDescription: String? {
        switch self {
        case .unreadableFile: return "the recording couldn't be read"
        }
    }
}

enum SoundImportError: LocalizedError {
    case fileTooLarge
    case tooLong
    case tooManySounds
    case unreadableFile

    var errorDescription: String? {
        switch self {
        case .fileTooLarge:
            return "that file is too big — riichi sounds must be under 25 MB"
        case .tooLong:
            return "riichi sounds must be \(Int(RiichiSoundStore.maxImportDuration)) seconds or shorter"
        case .tooManySounds:
            return "you already have \(RiichiSoundStore.maxCustomSounds) custom sounds — delete some first"
        case .unreadableFile:
            return "that file doesn't look like playable audio"
        }
    }
}

/// Records up to two seconds of audio from the microphone, lets the user
/// trim the result, and exports it into the RiichiSoundStore.
class RiichiSoundRecorder: NSObject, ObservableObject, AVAudioPlayerDelegate {
    enum RecorderState {
        case idle
        case recording
        case readyToSave
        case permissionDenied
    }

    static let maxDuration: TimeInterval = 2.0

    @Published private(set) var state: RecorderState = .idle
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var isPreviewPlaying = false
    @Published private(set) var previewTime: TimeInterval = 0
    @Published private(set) var waveformSamples: [Float] = []
    @Published var trimStart: TimeInterval = 0
    @Published var trimEnd: TimeInterval = RiichiSoundRecorder.maxDuration
    @Published var gain: Float = 1
    @Published var saveError: String?

    private var recorder: AVAudioRecorder?
    private var previewPlayer: AVAudioPlayer?
    private var meterTimer: Timer?
    private var previewStopTimer: Timer?
    private var previewPlayheadTimer: Timer?
    private var recordingURL: URL?
    private var previewTempURL: URL?

    // MARK: - Recording

    /// Asks for microphone permission, then starts recording.
    func startRecording() {
        saveError = nil
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.beginRecording()
                } else {
                    self?.state = .permissionDenied
                }
            }
        }
    }

    private func beginRecording() {
        stopPreview()
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            let url = FileManager.default.temporaryDirectory.appendingPathComponent("riichi_recording.m4a")
            try? FileManager.default.removeItem(at: url)

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let newRecorder = try AVAudioRecorder(url: url, settings: settings)
            recorder = newRecorder
            recordingURL = url
            elapsed = 0
            newRecorder.record()
            state = .recording

            meterTimer?.invalidate()
            meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let self, let recorder = self.recorder else { return }
                self.elapsed = recorder.currentTime
                if recorder.currentTime >= Self.maxDuration {
                    self.stopRecording()
                }
            }
        } catch {
            saveError = "couldn't start recording: \(error.localizedDescription)"
            state = .idle
            restorePlaybackSession()
        }
    }

    func stopRecording() {
        guard state == .recording else { return }
        meterTimer?.invalidate()
        meterTimer = nil

        let recordedDuration = max(0.1, min(elapsed, Self.maxDuration))
        recorder?.stop()
        duration = recordedDuration
        trimStart = 0
        trimEnd = recordedDuration
        state = .readyToSave
        restorePlaybackSession()

        // Load the waveform so the user can see what they are trimming.
        waveformSamples = []
        if let url = recordingURL {
            Task {
                let waveform = await WaveformData.load(from: url, bucketCount: 90)
                waveformSamples = waveform.samples
            }
        }
    }

    // MARK: - Preview

    func togglePreview() {
        if isPreviewPlaying {
            stopPreview()
        } else {
            playPreview()
        }
    }

    private func playPreview() {
        guard let recordingURL, trimEnd > trimStart else { return }

        // With a boost, render a temp copy at the boosted level so the
        // preview matches what will be saved (AVAudioPlayer volume caps at 1).
        if gain > 1.001 {
            let trimStart = self.trimStart
            let trimEnd = self.trimEnd
            let gain = self.gain
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("riichi_preview_\(UUID().uuidString).m4a")
            Task.detached(priority: .userInitiated) { [unowned self] in
                do {
                    try RiichiSoundRecorder.exportTrimmed(
                        source: recordingURL,
                        to: tempURL,
                        start: trimStart,
                        end: trimEnd,
                        gain: gain
                    )
                    await MainActor.run {
                        // The temp file contains only the trimmed range, so its
                        // timeline starts at 0; the playhead maps it onto the trim.
                        self.startPreviewPlayer(url: tempURL, seekTo: 0, tempFile: tempURL)
                    }
                } catch {
                    // Fall back to the unboosted recording if the render fails.
                    try? FileManager.default.removeItem(at: tempURL)
                    await MainActor.run {
                        self.startPreviewPlayer(url: recordingURL, seekTo: trimStart, tempFile: nil)
                    }
                }
            }
        } else {
            startPreviewPlayer(url: recordingURL, seekTo: trimStart, tempFile: nil)
        }
    }

    /// Starts playback of `url` at `seekTo` seconds, stopping at the end of the trim.
    /// The playhead maps `seekTo` onto the left trim handle, so playback always
    /// sweeps the selected region regardless of where the file's timeline starts.
    private func startPreviewPlayer(url: URL, seekTo: TimeInterval, tempFile: URL?) {
        stopPreview()
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.currentTime = seekTo
            player.prepareToPlay()
            player.play()
            previewPlayer = player
            previewTempURL = tempFile
            isPreviewPlaying = true

            previewStopTimer?.invalidate()
            previewStopTimer = Timer.scheduledTimer(withTimeInterval: trimEnd - trimStart, repeats: false) { [weak self] _ in
                self?.stopPreview()
            }

            // Keep the playhead position in sync while the preview plays.
            // seekTo maps onto the left handle (trimStart) on the waveform.
            previewTime = trimStart
            previewPlayheadTimer?.invalidate()
            previewPlayheadTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
                guard let self, let player = self.previewPlayer else { return }
                self.previewTime = min(self.trimStart + player.currentTime - seekTo, self.trimEnd)
            }
        } catch {
            if let tempFile {
                try? FileManager.default.removeItem(at: tempFile)
            }
            saveError = "couldn't play recording: \(error.localizedDescription)"
        }
    }

    func stopPreview() {
        previewStopTimer?.invalidate()
        previewStopTimer = nil
        previewPlayheadTimer?.invalidate()
        previewPlayheadTimer = nil
        previewPlayer?.stop()
        previewPlayer = nil
        if let previewTempURL {
            try? FileManager.default.removeItem(at: previewTempURL)
        }
        previewTempURL = nil
        isPreviewPlaying = false
        previewTime = 0
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.stopPreview()
        }
    }

    // MARK: - Saving

    /// Exports the trimmed selection into the sounds directory, applying the volume boost.
    func saveRecording(completion: @escaping (Bool) -> Void) {
        guard let recordingURL else {
            completion(false)
            return
        }
        stopPreview()

        // The custom-sound cap applies to recordings too, not just imports.
        guard RiichiSoundStore.shared.customSounds.count < RiichiSoundStore.maxCustomSounds else {
            saveError = SoundImportError.tooManySounds.localizedDescription
            completion(false)
            return
        }

        let destination = RiichiSoundStore.shared.uniqueDestinationURL(for: "recorded riichi.m4a")
        let trimStart = self.trimStart
        let trimEnd = self.trimEnd
        let gain = self.gain

        Task.detached(priority: .userInitiated) { [unowned self] in
            do {
                try Self.exportTrimmed(
                    source: recordingURL,
                    to: destination,
                    start: trimStart,
                    end: trimEnd,
                    gain: gain
                )
                await MainActor.run {
                    RiichiSoundStore.shared.refresh()
                    completion(true)
                }
            } catch {
                await MainActor.run {
                    self.saveError = "couldn't save: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }

    /// Writes the [start, end] region of `source` to `destination`, multiplying
    /// every sample by `gain` and clipping to full scale to avoid overflow.
    static func exportTrimmed(source: URL, to destination: URL, start: TimeInterval, end: TimeInterval, gain: Float) throws {
        let input = try AVAudioFile(forReading: source)
        let inputFormat = input.processingFormat
        let totalFrames = AVAudioFrameCount(input.length)
        guard totalFrames > 0,
              let fullBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: totalFrames) else {
            throw SoundExportError.unreadableFile
        }
        try input.read(into: fullBuffer)

        let sampleRate = inputFormat.sampleRate
        let startFrame = max(0, Int(start * sampleRate))
        let endFrame = min(Int(fullBuffer.frameLength), Int(end * sampleRate))
        let frameCount = max(1, endFrame - startFrame)

        guard let trimmedBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: AVAudioFrameCount(frameCount)) else {
            throw SoundExportError.unreadableFile
        }
        trimmedBuffer.frameLength = AVAudioFrameCount(frameCount)

        guard let sourceChannels = fullBuffer.floatChannelData,
              let trimmedChannels = trimmedBuffer.floatChannelData else {
            throw SoundExportError.unreadableFile
        }

        for channel in 0..<Int(inputFormat.channelCount) {
            for frame in 0..<frameCount {
                let sample = sourceChannels[channel][startFrame + frame] * gain
                trimmedChannels[channel][frame] = max(-1, min(1, sample))
            }
        }

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: inputFormat.channelCount
        ]
        let output = try AVAudioFile(forWriting: destination, settings: settings)
        let outputFormat = output.processingFormat

        let sameFormat = outputFormat.sampleRate == inputFormat.sampleRate
            && outputFormat.channelCount == inputFormat.channelCount
            && outputFormat.commonFormat == inputFormat.commonFormat
            && outputFormat.isInterleaved == inputFormat.isInterleaved

        if sameFormat {
            try output.write(from: trimmedBuffer)
        } else if let converter = AVAudioConverter(from: inputFormat, to: outputFormat) {
            guard let converted = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: trimmedBuffer.frameLength) else {
                throw SoundExportError.unreadableFile
            }
            var conversionError: NSError?
            var providedInput = false
            converter.convert(to: converted, error: &conversionError) { _, outStatus in
                if providedInput {
                    outStatus.pointee = .endOfStream
                    return nil
                }
                providedInput = true
                outStatus.pointee = .haveData
                return trimmedBuffer
            }
            if let conversionError {
                throw conversionError
            }
            try output.write(from: converted)
        } else {
            throw SoundExportError.unreadableFile
        }
    }

    /// Throws away any in-progress or finished recording and resets to idle.
    func discardRecording() {
        stopPreview()
        meterTimer?.invalidate()
        meterTimer = nil
        recorder?.stop()
        recorder = nil
        if let recordingURL {
            try? FileManager.default.removeItem(at: recordingURL)
        }
        recordingURL = nil
        elapsed = 0
        duration = 0
        trimStart = 0
        trimEnd = Self.maxDuration
        gain = 1
        previewTime = 0
        waveformSamples = []
        saveError = nil
        state = .idle
        restorePlaybackSession()
    }

    /// Puts the audio session back to plain playback so riichi sounds stay loud.
    private func restorePlaybackSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("error restoring audio session: \(error)")
        }
    }
}
