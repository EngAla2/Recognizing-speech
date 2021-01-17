//
//  ViewController.swift
//  Recognizing speech
//
//  Created by Ala'a Araishi on 1/15/21.
//

import UIKit
import Speech
class ViewController: UIViewController, AVAudioRecorderDelegate {
    var recordingSession: AVAudioSession!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textGoHere: UILabel!
    var audioRecorder: AVAudioRecorder!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        requestTranscribePermissions()
    }
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }
    }
    
    
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

            recordButton.setTitle("Tap to Stop", for: .normal)
            view.backgroundColor = .darkGray
        } catch {
            finishRecording(success: false)
        }
    }
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if success {
            transcribeAudio(url: getDocumentsDirectory().appendingPathComponent("recording.m4a"))
            recordButton.setTitle("Tap to Re-start", for: .normal)
            view.backgroundColor = .white
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    @IBAction func recordTapped(_ sender: Any) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }

    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    func transcribeAudio(url: URL) {
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)
        print("----------------------------------")
        // start recognition!
        recognizer?.recognitionTask(with: request) {(result, error) in
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("There was an error: \(error!)")
                return
            }

            // if we got the final transcription back, print it
            if result.isFinal {
                // pull out the best transcription...
                self.textGoHere.text = result.bestTranscription.formattedString
                print(result.bestTranscription.formattedString)
            }
        }
    }

}
