//
//  MainViewController.swift
//  TestApp
//
//  Created by Stanislav Demyanov on 03.06.2022.
//

import UIKit
import AVFoundation
import MobileCoreServices
import UniformTypeIdentifiers

class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameAudioFiles: UILabel!
    @IBOutlet weak var valueCrossfade: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addFileButtonOne: UIButton!
    @IBOutlet weak var addFileButtonTwo: UIButton!
    
    // MARK: - Private properties
    private var index = 0
    private var player: AVAudioPlayer?
    private var url = [URL?](repeating: nil, count: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func addAudioFileOne(_ sender: UIButton) {
        selectFile()
        crossfade()
        index = 1
    }
    
    @IBAction func addAudioFileSecond(_ sender: UIButton) {
        selectFile()
        index = 2
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        if let player = player, player.isPlaying {
            stop()
            playButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            play(0)
            playButton.setImage(UIImage(named: "stop"), for: .normal)
        }
    }
}
extension MainViewController: UIDocumentPickerDelegate, AVAudioPlayerDelegate {
    private func selectFile() {
        let documentPickerController = UIDocumentPickerViewController(
            forOpeningContentTypes: [UTType.audio])
        documentPickerController.delegate = self
        documentPickerController.allowsMultipleSelection = false
        documentPickerController.shouldShowFileExtensions = true
        present(documentPickerController, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else { return }
        if index == 1 {
            url.removeFirst()
            url.insert(selectedFileURL, at: 0)
            index = 0
            print(url)
        } else if index == 2 {
            if url.count > 1 {
                url.removeLast()
            }
            url.insert(selectedFileURL, at: 1)
            index = 0
            print(url)
        }
    }
    
    private func play(_ index: Int) {
        print("play \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url[index]!)
            player?.delegate = self
            player?.prepareToPlay()
            player?.volume = 1.0
            player?.play()
            player?.numberOfLoops = 0
            player?.setVolume(0.0,
                              fadeDuration: player!.duration - Double(valueCrossfade.value / 2))
            let durationTime = Int((player?.duration)!)
            print(durationTime)
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    private func stop() {
        player?.stop()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true {
            if index == 0 {
                play(1)
                index += 1
            } else {
                play(0)
                index -= 1
            }
        }
    }
    
    func crossfade() {
        let params = AVMutableAudioMixInputParameters()
        params.setVolumeRamp(fromStartVolume: 1, toEndVolume: 0, timeRange: .init(start: .zero, end: CMTime(seconds: Double(valueCrossfade.value), preferredTimescale: .max)))
    }
}
