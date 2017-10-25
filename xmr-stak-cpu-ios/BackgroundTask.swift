//
//  BackgroundTask.swift
//
//  Created by Yaro on 8/27/16.
//  Copyright © 2016 Yaro. All rights reserved.
//

import AVFoundation

class BackgroundTask {
    
    var player = AVAudioPlayer()
    
    let data = Data(bytes:
                [0x52, 0x49, 0x46, 0x46, 0x26, 0x0, 0x0, 0x0, 0x57, 0x41,
                 0x56, 0x45, 0x66, 0x6d, 0x74, 0x20, 0x10, 0x0, 0x0, 0x0,
                 0x1, 0x0, 0x1, 0x0, 0x44, 0xac, 0x0, 0x0, 0x88, 0x58, 0x1,
                 0x0, 0x2, 0x0, 0x10, 0x0, 0x64, 0x61, 0x74, 0x61, 0x2, 0x0,
                 0x0, 0x0, 0xfc, 0xff])
    
    func startBackgroundTask() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(interuptedAudio),
                                               name: NSNotification.Name.AVAudioSessionInterruption,
                                               object: AVAudioSession.sharedInstance())
        self.playAudio()
    }
    
    func stopBackgroundTask() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVAudioSessionInterruption,
                                                  object: nil)
        player.stop()
    }
    
    @objc fileprivate func interuptedAudio(_ notification: Notification) {
        if notification.name == NSNotification.Name.AVAudioSessionInterruption &&
            notification.userInfo != nil {
            let info = notification.userInfo!
            var intValue = 0
            (info[AVAudioSessionInterruptionTypeKey]! as AnyObject).getValue(&intValue)
            if intValue == 1 {
                playAudio()
            }
        }
    }
    
    fileprivate func playAudio() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayback,
                                    with:AVAudioSessionCategoryOptions.mixWithOthers)
            try session.setActive(true)
            try self.player = AVAudioPlayer(data: self.data)
            self.player.numberOfLoops = -1
            self.player.volume = 0.01
            self.player.prepareToPlay()
            self.player.play()
        } catch { print(error) }
    }
}
