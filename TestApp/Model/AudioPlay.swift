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
    private var fadeTimer: Timer?
    
    func play(_ urls: [URL], time: Float) {
        for url in urls {
            let item = AVPlayerItem(url: url)
            
            queuePlayer.insert(item, after: queuePlayer.items().last)
        }
        
        queuePlayer.volume = 0
        queuePlayer.play()
    }
    
    func stop() {
        queuePlayer.pause()
    }
}
