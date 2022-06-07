//
//  AudioPlay.swift
//  TestApp
//
//  Created by Stanislav Demyanov on 05.06.2022.
//

import Foundation
import AVFoundation


class AudioPlay {
    
    private let queuePlayer = AVQueuePlayer()
    private var token: NSKeyValueObservation?
    
    func play(_ urls: [URL], _ time: Double) {
        let time = time.rounded()
        print(urls.description)
        // First track
        let asset = AVURLAsset(url: urls[0])
        let firstTrack = asset.tracks.last!
//
        let duration = firstTrack.timeRange.duration.seconds
        let composition = AVMutableComposition()
        let audioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))

        try! audioTrack?.insertTimeRange(CMTimeRange(start: .zero, end: CMTime(seconds: duration, preferredTimescale: 600)),
                                        of: firstTrack,
                                         at: .zero)

        // Second track
        let secondAsset = AVURLAsset(url: urls[1])
        let secondTrack = secondAsset.tracks.last!
        let secondDuration = secondTrack.timeRange.duration.seconds
        let secondAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))

        try! secondAudioTrack?.insertTimeRange(CMTimeRange(start: CMTime(seconds: .zero, preferredTimescale: 600), end: CMTime(seconds: secondDuration, preferredTimescale: 600)),
                                               of: secondTrack,
                                               at: CMTime(seconds: duration - time, preferredTimescale: 600))

        //Fade in and out
        let params = AVMutableAudioMixInputParameters(track: asset.tracks.last! as AVAssetTrack)
        let secondParams = AVMutableAudioMixInputParameters(track: secondAsset.tracks.last! as AVAssetTrack)

        params.setVolumeRamp(fromStartVolume: 0, toEndVolume: 1, timeRange: CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 600),
                                                                                        end: CMTime(seconds: duration - (duration - time), preferredTimescale: 600)))
        
        params.setVolumeRamp(fromStartVolume: 1, toEndVolume: 0, timeRange: CMTimeRange(start: CMTime(seconds: duration - time, preferredTimescale: 600),
                                                                                        end: CMTime(seconds: duration, preferredTimescale: 600)))
        
        secondParams.setVolumeRamp(fromStartVolume: 0, toEndVolume: 1, timeRange: CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 600),
                                                                                              end: CMTime(seconds: secondDuration - (secondDuration - time), preferredTimescale: 600)))

        secondParams.setVolumeRamp(fromStartVolume: 1, toEndVolume: 0, timeRange: CMTimeRange(start: CMTime(seconds: (composition.tracks.last?.timeRange.duration.seconds)! - time, preferredTimescale: 600),
                                                                                              end: CMTime(seconds: (composition.tracks.last?.timeRange.end.seconds)!, preferredTimescale: 600)))
        
        let mix = AVMutableAudioMix()
        mix.inputParameters = [secondParams]
        let item = AVPlayerItem(asset: composition)
        
        item.audioMix = mix
        
        queuePlayer.insert(item, after: queuePlayer.items().last)
        queuePlayer.play()
        
        // AudioLoop
        token = queuePlayer.observe(\.currentItem) { [weak self] queuePlayer, _ in
            if queuePlayer.items().count == 0 {
                self?.play(urls, time)
            }
        }
    }
    
    func stop() {
        queuePlayer.pause()
        queuePlayer.seek(to: .zero)
    }
}
