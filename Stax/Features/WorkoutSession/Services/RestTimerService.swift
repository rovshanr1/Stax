//
//  RestTimerManager.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.09.26.
//

import Foundation
import Combine

enum RestTimerState: Equatable {
    case idle
    case running(remainingSeconds: Double, progress: Float, timeString: String)
    case finished
}

protocol RestTimerServiceProtocol{
    var currentState: RestTimerState { get }
    var statePublisher: AnyPublisher<RestTimerState, Never> { get }
    
    func start(for duration: Double)
    func stop()
}

final class RestTimerService: RestTimerServiceProtocol {
    private let stateSubject = CurrentValueSubject<RestTimerState, Never>(.idle)

    private var timer: Timer?
    private var targetDate: Date?
    private var totalDuration: Double = 0
    
    var currentState: RestTimerState {
        stateSubject.value
    }
    
    var statePublisher: AnyPublisher<RestTimerState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    func start(for duration: Double) {
        
        guard duration > 0 else {
            stop()
            return
        }
        
        stop()
        
        self.totalDuration = duration
        
        self.targetDate = Date().addingTimeInterval(duration)
        
        updateState()
        
        let newTimer = Timer(timeInterval: 0.1, repeats: true) {[weak self] _ in
            self?.updateState()
        }
        
        timer = newTimer
        
        RunLoop.current.add(newTimer, forMode: .common)
        
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        targetDate = nil
        stateSubject.send(.idle)
    }
    
    deinit{
        timer?.invalidate()
    }
    
    private func updateState() {
        guard let targetDate else { return }
        
        let remainingTime = targetDate.timeIntervalSince(Date())
        
        if remainingTime > 0 {
            let progress = Float(remainingTime / totalDuration)
            let timeString = remainingTime.formatDuration()
            
            stateSubject.send(.running(remainingSeconds: remainingTime, progress: progress, timeString: timeString))
        }else{
            timer?.invalidate()
            timer = nil
            self.targetDate = nil
            
            stateSubject.send(.finished)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {[weak self] in
                if self?.stateSubject.value == .finished {
                    self?.stateSubject.send(.idle)
                }
            }
        }
    }
}
