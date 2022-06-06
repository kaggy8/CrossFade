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
        
        
        for url in urls {
            
            let asset = AVURLAsset(url: url)
            let duration = asset.duration.seconds
            let time = time.rounded()
            
//            let composition =  AVMutableComposition()
//            let audioTrack: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaType.audio,
//                                                                                     preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//
//            try? audioTrack?.insertTimeRange(CMTimeRange(start: CMTime(seconds: .zero, preferredTimescale: 600), end: CMTime(seconds: duration, preferredTimescale: 600)),
//                                             of: asset.tracks.first!,
//                                             at: .zero)
//
//            try? audioTrack?.insertTimeRange(CMTimeRange(start: CMTime(seconds: .zero, preferredTimescale: 600), end: CMTime(seconds: duration, preferredTimescale: 600)),
//                                             of: asset.tracks.last!,
//                                             at: .zero)
            
            
            //Fade in and out
            let params = AVMutableAudioMixInputParameters(track: asset.tracks.first! as AVAssetTrack)
            let firstSecond = CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 600),
                                          end: CMTime(seconds: duration - (duration - time), preferredTimescale: 600))
            let lastSecond = CMTimeRange(start: CMTime(seconds: Double(duration - time), preferredTimescale: 600),
                                         end: CMTime(seconds: Double(duration), preferredTimescale: 600))
            
            params.setVolumeRamp(fromStartVolume: 0, toEndVolume: 1, timeRange: firstSecond)
            params.setVolumeRamp(fromStartVolume: 1, toEndVolume: 0, timeRange: lastSecond)
            
            let mix = AVMutableAudioMix()
            mix.inputParameters = [params]
            let item = AVPlayerItem(asset: asset)
            
            item.audioMix = mix
            
            queuePlayer.insert(item, after: queuePlayer.items().last)
        }
        print(queuePlayer.description)
        queuePlayer.play()
        
        // AudioLoop
        token = queuePlayer.observe(\.currentItem) { [weak self] queuePlayer, _ in
            if queuePlayer.items().count == 1 {
                self?.play(urls, time)
            }
        }
    }
    
    func stop() {
        queuePlayer.pause()
    }
}
