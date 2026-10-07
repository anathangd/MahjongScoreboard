//
//  WaveformView.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 10/7/26.
//

import SwiftUI
import AVFoundation

/// Reads the peak amplitude of each audio channel into normalized 0...1
/// buckets so a recording can be drawn as a waveform.
struct WaveformData {
    let samples: [Float]

    static func load(from url: URL, bucketCount: Int) async -> WaveformData {
        await Task.detached(priority: .userInitiated) {
            computeSamples(from: url, bucketCount: bucketCount)
        }.value
    }

    private static func computeSamples(from url: URL, bucketCount: Int) -> WaveformData {
        guard bucketCount > 0,
              let file = try? AVAudioFile(forReading: url) else {
            return WaveformData(samples: [])
        }

        let frameCount = AVAudioFrameCount(file.length)
        guard frameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount),
              (try? file.read(into: buffer)) != nil,
              let channelData = buffer.floatChannelData else {
            return WaveformData(samples: [])
        }

        let totalFrames = Int(buffer.frameLength)
        guard totalFrames > 0 else {
            return WaveformData(samples: [])
        }

        let channelCount = Int(buffer.format.channelCount)
        let framesPerBucket = max(1, totalFrames / bucketCount)
        var peaks: [Float] = []
        peaks.reserveCapacity(bucketCount)

        for bucket in 0..<bucketCount {
            let startFrame = bucket * framesPerBucket
            guard startFrame < totalFrames else { break }
            let endFrame = min(startFrame + framesPerBucket, totalFrames)

            var peak: Float = 0
            for channel in 0..<channelCount {
                let samples = UnsafeBufferPointer(start: channelData[channel] + startFrame, count: endFrame - startFrame)
                if let channelPeak = samples.max(by: { abs($0) < abs($1) }) {
                    peak = max(peak, abs(channelPeak))
                }
            }
            peaks.append(peak)
        }

        // Normalize so the loudest bucket reaches full height.
        if let maxPeak = peaks.max(), maxPeak > 0 {
            peaks = peaks.map { $0 / maxPeak }
        }

        return WaveformData(samples: peaks)
    }
}

/// Draws the waveform and lets the user drag either end to trim the clip.
struct WaveformTrimView: View {
    let samples: [Float]
    let duration: TimeInterval
    @Binding var trimStart: TimeInterval
    @Binding var trimEnd: TimeInterval
    var isPlaying: Bool = false
    var playhead: TimeInterval = 0
    var gain: Float = 1

    private let minimumClipLength: TimeInterval = 0.05
    private let handleWidth: CGFloat = 14

    var body: some View {
        GeometryReader { geometry in
            let width = max(1, geometry.size.width)
            let startX = xPosition(for: trimStart, width: width)
            let endX = xPosition(for: trimEnd, width: width)

            ZStack(alignment: .leading) {
                waveformShape(width: width)

                // dim the parts of the clip that will be cut
                Rectangle()
                    .fill(Color.black.opacity(0.65))
                    .frame(width: startX)
                Rectangle()
                    .fill(Color.black.opacity(0.65))
                    .frame(width: width - endX)
                    .offset(x: endX)

                // playhead
                if isPlaying {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2)
                        .offset(x: xPosition(for: playhead, width: width) - 1)
                }

                trimHandle(x: startX, color: .mint)
                    .offset(x: startX - handleWidth / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newTime = time(for: value.location.x, width: width)
                                trimStart = min(max(0, newTime), trimEnd - minimumClipLength)
                            }
                    )

                trimHandle(x: endX, color: .mint)
                    .offset(x: endX - handleWidth / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newTime = time(for: value.location.x, width: width)
                                trimEnd = max(min(duration, newTime), trimStart + minimumClipLength)
                            }
                    )
            }
        }
        .frame(height: 100)
    }

    private func trimHandle(x: CGFloat, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(width: handleWidth, height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 3, height: 30)
            )
            .contentShape(Rectangle().size(width: handleWidth + 20, height: 110))
    }

    private func waveformShape(width: CGFloat) -> some View {
        Canvas { context, size in
            guard !samples.isEmpty, duration > 0 else {
                // placeholder while samples are loading
                let barWidth = size.width / 24
                for index in 0..<24 {
                    let height = size.height * 0.1
                    let rect = CGRect(
                        x: CGFloat(index) * barWidth + barWidth * 0.2,
                        y: (size.height - height) / 2,
                        width: barWidth * 0.6,
                        height: height
                    )
                    context.fill(Path(roundedRect: rect, cornerRadius: barWidth * 0.3), with: .color(.gray.opacity(0.6)))
                }
                return
            }

            let barWidth = size.width / CGFloat(samples.count)
            for (index, sample) in samples.enumerated() {
                let boosted = sample * gain
                let height = max(2, min(1, CGFloat(boosted)) * size.height)
                let rect = CGRect(
                    x: CGFloat(index) * barWidth + barWidth * 0.15,
                    y: (size.height - height) / 2,
                    width: barWidth * 0.7,
                    height: height
                )
                // Bars that will clip after the volume boost are drawn red.
                let color: Color = boosted >= 0.995 ? .red : .white
                context.fill(Path(roundedRect: rect, cornerRadius: barWidth * 0.3), with: .color(color))
            }
        }
        .frame(width: width, height: 100)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func xPosition(for time: TimeInterval, width: CGFloat) -> CGFloat {
        guard duration > 0 else { return 0 }
        return CGFloat(time / duration) * width
    }

    private func time(for x: CGFloat, width: CGFloat) -> TimeInterval {
        TimeInterval(max(0, min(x, width)) / width) * duration
    }
}
