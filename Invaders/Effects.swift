//
//  Effects.swift
//  Invaders
//
//  Created by Siddharth Subramanian on 3/28/24.
//

import AVFoundation

class Effect {
    
    var audioPlayerNode = AVAudioPlayerNode()
    var audioUnitTimePitch = AVAudioUnitTimePitch()
    var audioFile: AVAudioFile
    var audioBuffer: AVAudioPCMBuffer
    var name: String
    var engine: AVAudioEngine
    var isPlaying = false
    
    init?(forSound sound: String, withEngine avEngine: AVAudioEngine) {
        do {
            audioPlayerNode.stop()
            name = sound
            engine = avEngine
            
            let file = NSURL(fileURLWithPath: Bundle.main.path(forResource: sound, ofType: "wav")!) as URL
            try audioFile = AVAudioFile(forReading: file)
            if let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length)) {
                audioBuffer = buffer
                try audioFile.read(into: audioBuffer)
                engine.attach(audioPlayerNode)
                engine.attach(audioUnitTimePitch)
                engine.connect(audioPlayerNode, to: audioUnitTimePitch, format: audioBuffer.format)
                engine.connect(audioUnitTimePitch, to: engine.mainMixerNode, format: audioBuffer.format)
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func play(pitch: Float, speed: Float) {
        if !engine.isRunning {
            engine.reset()
            try! engine.start()
        }
        
        audioPlayerNode.play()
        audioUnitTimePitch.pitch = pitch
        audioUnitTimePitch.rate = speed
        audioPlayerNode.scheduleBuffer(audioBuffer) {
            self.isPlaying = false
        }
        
        isPlaying = true
    }
}

class Sounds {
    
    let engine = AVAudioEngine()
    var effects: [Effect] = []
    
    func getEffect(_ sound: String) -> Effect? {
        if let effect = effects.first(where: { return isReady($0, sound) }) {
            return effect
        } else {
            if let effect = Effect(forSound: sound, withEngine: engine) {
                effects.append(effect)
                return effect
            } else {
                return nil
            }
        }
    }
    
    private func isReady(_ effect: Effect, _ sound: String) -> Bool {
        return effect.name == sound && effect.isPlaying == false
    }
    
    func preload(_ name: String) {
        let _ = getEffect(name)
    }
    
    func play(_ name: String, pitch: Float, speed: Float) {
        if let effect = getEffect(name) {
            effect.play(pitch: pitch, speed: speed)
        }
    }
    
    func play(_ name: String) {
        play(name, pitch: 0.0, speed: 1.0)
    }
    
    func play(_ name: String, pitch: Float) {
        play(name, pitch: pitch, speed: 1.0)
    }
    
    func play(_ name: String, speed: Float) {
        play(name, pitch: 0.0, speed: speed)
    }
    
    func disposeSounds() {
        effects.removeAll()
    }
}
