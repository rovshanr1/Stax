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
    var secondsElapsed: Double {get}
    func start()
    func stop()
    func setInitialTime(_ seconds: Double)
}

final class WorkoutTimerService: WorkoutTimerServiceProtocol{
    let timerPublisher = PassthroughSubject<String, Never>()
    var secondsElapsed: Double = 0.0
    private var timer: Timer?
    
    func start() {
        guard timer == nil else {return}
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self else {return}
            
            self.secondsElapsed += 1
            self.timerPublisher.send(self.secondsElapsed.formatDuration())
        })
        
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    
    func setInitialTime(_ seconds: Double) {
        self.secondsElapsed = seconds
        timerPublisher.send(seconds.formatDuration())
    }
}
