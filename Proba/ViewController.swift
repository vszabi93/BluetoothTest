import UIKit
import AVFoundation

class ViewController: UIViewController {

    var audioEngine: AVAudioEngine!
    var audioInputNode: AVAudioInputNode!
    var audioOutputNode: AVAudioOutputNode!
    var audioFormat: AVAudioFormat!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Request microphone permission
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if !hasPermission {
                print("Permission denied")
            }
        }
    }

    @IBAction func startRecordingTapped(_ sender: UIButton) {
        startRecordingAndPlayback()
    }

    @IBAction func playRecordingTapped(_ sender: UIButton) {
        stopAudioSession()
    }

    func startAudioSession() {
            do {
                let session = AVAudioSession.sharedInstance()
                // Set the session for both play and record
                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers, .allowBluetooth, .allowBluetoothA2DP])
                try session.setActive(true)
                try session.setPreferredSampleRate(24000)
                // Set the preferred input (headphone mic)
                let availableInputs = session.availableInputs ?? []
                for input in availableInputs {
                    if input.portType == .headsetMic || input.portType == .bluetoothA2DP {  // Check if the input is a headphone mic
                        try session.setPreferredInput(input)  // Set headphone mic as the input source
                        print("Headphone mic selected as input")
                        break
                    }
                }

                // Set the preferred output to the built-in speaker (even if headphones are plugged in)
                try session.overrideOutputAudioPort(.speaker) // Force output to the built-in speaker

                // Connect input node (microphone) to output node (speaker)
                audioEngine.connect(audioInputNode, to: audioOutputNode, format: audioFormat)

                // Start audio engine to begin streaming
                try audioEngine.start()

                print("Started live streaming to speaker.")
            } catch {
                print("Error starting audio session: \(error)")
            }
        }

        func stopAudioSession() {
            do {
                audioEngine.stop()
                let session = AVAudioSession.sharedInstance()
                try session.setActive(false)
                print("Audio session stopped.")
            } catch {
                print("Error stopping audio session: \(error)")
            }
        }

    func startRecordingAndPlayback() {
        // Setup the Audio Engine
        audioEngine = AVAudioEngine()

        // Get the audio format from the input node (microphone)
        audioInputNode = audioEngine.inputNode
        audioOutputNode = audioEngine.outputNode
        audioFormat = audioInputNode.inputFormat(forBus: 0)
        // Setup the Audio Session
        startAudioSession()
    }

}

