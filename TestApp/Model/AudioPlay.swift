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
    
    func play(_ urls: [URL]) {
        for url in urls {
            let item = AVPlayerItem(url: url)
            queuePlayer.insert(item, after: queuePlayer.items().last)
        }
        
        queuePlayer.volume = 1
        queuePlayer.play()
        token = queuePlayer.observe(\.currentItem) { [weak self] queuePlayer, _ in
            if queuePlayer.items().count == 1 {
                self?.play(urls)
            }
        }
    }
    
    func stop() {
        queuePlayer.pause()
    }
}
