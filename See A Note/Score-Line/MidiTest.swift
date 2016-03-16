//
//  MIDI.swift
//  SwiftAVFound
//
//  Created by Gene De Lisa on 8/11/14.
//  Copyright (c) 2014 Gene De Lisa. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

/**
Uses an AVAudioEngine with a AVAudioUnitSampler, which is a AVAudioUnitMIDIInstrument subclass.
That means you can send the sampler MIDI messages.
The sampler uses a Sound Font. In this class there is one sampler, so the instruments are
swapped in when a message is sent. For multi instrument polyphony, you'd need more than one sampler.
It subclasses NSObject so we can add it as a target.
*/
class MidiTest : NSObject {
    var engine:AVAudioEngine!
    var playerNode:AVAudioPlayerNode!
    var mixer:AVAudioMixerNode!
    var sampler:AVAudioUnitSampler!
    /// soundbanks are either dls or sf2. see http://www.sf2midi.com/
    var soundbank:NSURL!
    let melodicBank:UInt8 = UInt8(kAUSampler_DefaultMelodicBankMSB)
    /// general midi number for marimba
    let gmMarimba:UInt8 = 12
    let gmHarpsichord:UInt8 = 6

    override init() {
        super.init()
        initAudioEngine()
        loadMIDIFile()
    }

    func initAudioEngine () {
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        engine.attachNode(playerNode)
        mixer = engine.mainMixerNode
        engine.connect(playerNode, to: mixer, format: mixer.outputFormatForBus(0))

        // MIDI
        sampler = AVAudioUnitSampler()
        engine.attachNode(sampler)
        engine.connect(sampler, to: engine.outputNode, format: nil)

        soundbank = NSBundle.mainBundle().URLForResource("GeneralUser GS MuseScore v1.442", withExtension: "sf2")

        print(soundbank)

        do {
            try engine.start()
        }
        catch {
            print("failed: engine.start()")
        }
    }



    var mp:AVMIDIPlayer!

    func loadMIDIFile() {
        self.soundbank = NSBundle.mainBundle().URLForResource("GeneralUser GS MuseScore v1.442", withExtension: "sf2")

        // a standard MIDI file.
        var contents:NSURL = NSBundle.mainBundle().URLForResource("ntbldmtn", withExtension: "mid")!

        do {
            try self.mp = AVMIDIPlayer(contentsOfURL: contents, soundBankURL: soundbank)
            if self.mp == nil {
                print("nil midi player")
            }
        }
        catch {
            print("failed: engine.start()")
        }

        self.mp.prepareToPlay()
    }

    func playMIDIFile() {
        self.mp.play({
            print("midi done")
        })
    }
    

    func playSequence() {
        if engine.running {
            print("stopping the engine")
            engine.stop()
        }
        engine.musicSequence = sequence()
        do {
            try engine.start()
            print("started the engine")
        }
        catch {
            print("failed: playSequence()")
        }

    }



    func sequence() -> MusicSequence {
        var status : OSStatus = 0
        var midiSequence: MusicSequence = MusicSequence()
        status = NewMusicSequence(&midiSequence)

        var track: MusicTrack = MusicTrack()
        status = MusicSequenceNewTrack (midiSequence, &track)

        var message: MIDINoteMessage = MIDINoteMessage(channel: 0, note: 60, velocity: 64, releaseVelocity: 0, duration: 1.0)
        var timeStamp: MusicTimeStamp = 0
        status = MusicTrackNewMIDINoteEvent (track, timeStamp, &message)

        message = MIDINoteMessage(channel: 0, note: 65, velocity: 64, releaseVelocity: 0, duration: 1.0)
        timeStamp = 5
        status = MusicTrackNewMIDINoteEvent (track, timeStamp, &message)

        return midiSequence
    }
    
}