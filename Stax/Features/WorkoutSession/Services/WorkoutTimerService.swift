//
//  WorkoutTimerService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.01.26.
//

import Foundation
import Combine

protocol WorkoutTimerServiceProtocol {
    var timerPublisher: AnyPublisher<String, Never> {get}
    var secondsElapsed: Double {get}
    func start()
    func stop()
    func setInitialTime(_ seconds: Double)
}

final class WorkoutTimerService: WorkoutTimerServiceProtocol{
    private let timerSubject = CurrentValueSubject<String, Never>("00")
    
    var timerPublisher: AnyPublisher<String, Never>{
        timerSubject.eraseToAnyPublisher()
    }
    
    private(set) var secondsElapsed: Double = 0.0
    private var timer: Timer?
    
    private var startTime: Date?
    private var initialTimeOffset: Double = 0.0
    
    func start() {
        guard timer == nil else {return}
        
        startTime = Date()
        
        let newTimer = Timer(timeInterval: 1.0, repeats: true){[weak self] _ in
            
            self?.tick()
        }
        
        timer = newTimer
        
        RunLoop.main.add(newTimer, forMode: .common)
    }
    
    private func tick(){
        guard let startTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime) + initialTimeOffset
        
        self.secondsElapsed = elapsed
        self.timerSubject.send(elapsed.formatDuration())
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        
        initialTimeOffset = secondsElapsed
        startTime = nil
    }
    
    deinit{
        timer?.invalidate()
    }
    
    func setInitialTime(_ seconds: Double) {
        self.initialTimeOffset = seconds
        self.secondsElapsed = seconds
        timerSubject.send(seconds.formatDuration())
    }
}
