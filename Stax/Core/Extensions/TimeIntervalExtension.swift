//
//  TimeIntervalExtension.swift
//  Stax
//
//  Created by Rovshan Rasulov on 27.03.26.
//

import Foundation

extension TimeInterval{
     func formatDuration() -> String{
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if minutes == 0{
            return String(format: "%02dsec",  seconds)
        } else if hours == 0 {
            return String(format: "%02dmin %02dsec", minutes, seconds)
        }else{
            return String(format: "%02dh %02dmin %02dsec", hours, minutes, seconds)
        }
    }
    
    func formatDurationFromProfile() -> String{
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        
        return formatter.string(from: self) ?? "0 min"
    }
}


