//
//  CMTime.swift
//  Podcast
//
//  Created by William Yeung on 11/10/20.
//

import AVKit

extension CMTime {
    func toDisplayString() -> String {
        let totalSeconds = CMTimeGetSeconds(self)
        guard !totalSeconds.isNaN && !totalSeconds.isInfinite else { return "--:--:--" }
        
        let seconds = Int(totalSeconds) % 60
        let minutes = (Int(totalSeconds) / 60) % 60
        let hours = Int(totalSeconds) / 3600
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
