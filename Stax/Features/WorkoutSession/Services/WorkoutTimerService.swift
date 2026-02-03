//
//  WorkoutTimerService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.01.26.
//

import Foundation
import Combine

protocol WorkoutTimerServiceProtocol {
    var timerPublisher: PassthroughSubject<String, Never> {get}
    var seconsElapsed: Int{get}
    func start()
    func stop()
}

final class WorkoutTimerService: WorkoutTimerServiceProtocol{
    let timerPublisher = PassthroughSubject<String, Never>()
    var seconsElapsed: Int = 0
    private var timer: Timer?
    
    func start() {
        guard timer == nil else {return}
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self else {return}
            
            self.seconsElapsed += 1
            self.timerPublisher.send(self.formatTime(self.seconsElapsed))
        })
        
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%2dh %2dm %2ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%2dm %2ds", minutes, seconds)
        } else {
            return String(format: "%2ds", seconds)
        }
    }
}
