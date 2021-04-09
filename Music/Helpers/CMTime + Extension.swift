//
//  CMTime + Extension.swift
//  Music
//
//  Created by Иван Изюмкин on 29.03.2021.
//

import Foundation
import AVKit

extension CMTime {
    
    func toDisplayString() -> String {
        
        guard !CMTimeGetSeconds(self).isNaN else { return "" }
        let totalSecond = Int(CMTimeGetSeconds(self))
        let seconds = totalSecond % 60
        let minute = totalSecond / 60
        let timeFormatString = String(format: "%02d:%02d", minute, seconds)
        return timeFormatString
        
    }
    
}
