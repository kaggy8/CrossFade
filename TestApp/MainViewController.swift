//
//  MainViewController.swift
//  TestApp
//
//  Created by Stanislav Demyanov on 03.06.2022.
//

import UIKit
import UniformTypeIdentifiers
import MobileCoreServices

class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameAudioFiles: UILabel!
    @IBOutlet weak var valueCrossfade: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addFileButtonOne: UIButton!
    @IBOutlet weak var addFileButtonTwo: UIButton!
    
    // MARK: - Private properties
    private var index = 0
    private var url = [URL]()
    private let audioPlay = AudioPlay()
    
    // MARK: - Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func addAudioFileOne(_ sender: UIButton) {
        index = 1
        selectFile()
    }
    
    @IBAction func addAudioFileSecond(_ sender: UIButton) {
        index = 2
        selectFile()
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        switch index {
        case 0:
            audioPlay.play(url, Double(valueCrossfade.value))
            playButton.setImage(UIImage(named: "stop"), for: .normal)
            index = 1
        case 1:
            audioPlay.stop()
            playButton.setImage(UIImage(named: "play"), for: .normal)
            index = 0
        default:
            break
        }
    }
}

// MARK: - UIDocumentPicker

extension MainViewController: UIDocumentPickerDelegate {
    
    func selectFile() {
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
        documentPickerController.delegate = self
        documentPickerController.allowsMultipleSelection = false
        documentPickerController.shouldShowFileExtensions = true
        present(documentPickerController, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else { return }
        if index == 1 {
            if !url.isEmpty {
                url.removeFirst()
            }
            url.insert(selectedFileURL, at: 0)
            index = 0
        } else if index == 2 {
            if url.count > 1 {
                url.removeLast()
                url.insert(selectedFileURL, at: 1)
            } else if !url.isEmpty {
                url.insert(selectedFileURL, at: 1)
            } else {
                url.insert(selectedFileURL, at: 0)
            }
            index = 0
        }
    }
}
