//
//  WorkoutSessionViewModel.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.12.25.
//

import UIKit
import Combine

final class WorkoutSessionViewModel{
    //MARK: - I/O Structs
    //Input: "Orders" fromd the VC (Orders)
    struct Input{
        let viewDidLoad: PassthroughSubject<Void, Never>
        let didTapFinish: PassthroughSubject<Void, Never>
        let didTapCancel: PassthroughSubject<Void, Never>
    }
    
    //Output: "Data" to VC (Data Streams)
    struct Output{
        let timerSubject: CurrentValueSubject<String, Never>
        let dissmisEvent: PassthroughSubject<Void, Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var secondsElapsed = 0
    
    //MARK: - Initializer
    init() {
        self.input = .init(viewDidLoad: .init(),
                           didTapFinish: .init(),
                           didTapCancel: .init())
        self.output = .init(timerSubject: .init("00s"),
                            dissmisEvent: .init())
        
        transform()
        
    }
    
    //MARK: - Transform method
    private func transform() {
        input.viewDidLoad
            .sink { [weak self] in
                self?.startTimer()
            }
            .store(in: &cancellables)
        
        input.didTapFinish
            .sink { [weak self] in
                guard let self else { return }
                
                self.stopTimer()
                
                //TODO: - The registration process that will be done when the finish button is pressed will be done here.
                
                self.output.dissmisEvent.send()
            }
            .store(in: &cancellables)
        
        input.didTapCancel
            .sink { [weak self] in
                self?.stopTimer()
                self?.output.dissmisEvent.send()
            }
            .store(in: &cancellables)
        
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            self.secondsElapsed += 1
            let formatted = self.formatTime(self.secondsElapsed)
            
            self.output.timerSubject.send(formatted)
        })
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02dh:%02dm:%02ds", hours, minutes, seconds)
        }else if minutes > 0 {
            return String(format: "%02dm:%02ds", minutes, seconds)
        }else {
            return String(format: "%02ds", seconds)
        }
    }
}
