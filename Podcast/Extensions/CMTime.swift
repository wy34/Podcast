//
//  CMTime.swift
//  Podcast
//
//  Created by William Yeung on 11/10/20.
//

import AVKit

extension CMTime {
    func toDisplayString() -> String {
        let totalSeconds = Int(CMTimeGetSeconds(self))
        
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
