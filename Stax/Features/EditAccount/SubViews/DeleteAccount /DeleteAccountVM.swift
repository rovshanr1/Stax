//
//  DeleteAccountVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 03.06.26.
//

import Foundation
import Combine

final class DeleteAccountVM {
    
    struct Input {
        let currentPassword: CurrentValueSubject<String, Never>
        let deleteButtonTapped: PassthroughSubject<Void, Never>
        
        let viewDidAppear: PassthroughSubject<Void, Never>
        let viewDidDisappear: PassthroughSubject<Void, Never>
    }
    
    struct Output {
        let isDeleteButtonEnabled: CurrentValueSubject<Bool, Never>
        let isLoading: CurrentValueSubject<Bool, Never>
        let errorMessage: PassthroughSubject<String, Never>
        let isDeleteSuccessful: PassthroughSubject<Void, Never>
        
        let countdownText: CurrentValueSubject<String?, Never>
    }
    
    let input: Input
    let output: Output
    
    //MARK: - Private Properties
    private var timerCancellable: AnyCancellable?
    private var remainingSeconds = 10
    
    //Services
    private let authService: AuthServiceProtocol
    private let syncService: FirebaseSyncServiceInterface
    private let wipeService: UserDataWipeServiceProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(authService: AuthServiceProtocol = AuthService(),
         syncService: FirebaseSyncServiceInterface = FirebaseSyncService(),
         wipeService: UserDataWipeServiceProtocol = UserDataWipeService()
    ) {
        
        self.authService = authService
        self.syncService = syncService
        self.wipeService = wipeService
        
        self.input = .init(currentPassword: .init(""),
                           deleteButtonTapped: .init(),
                           viewDidAppear: .init(),
                           viewDidDisappear: .init()
        )
        
        self.output = .init(isDeleteButtonEnabled: .init(false),
                            isLoading: .init(false),
                            errorMessage: .init(),
                            isDeleteSuccessful: .init(),
                            countdownText: .init("")
        )
        
        transform()
    }
    
    private func transform() {
        input.currentPassword
            .combineLatest(output.countdownText)
            .map {password, countdownText in
                let isPasswordValid = !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                let isTimerFinished = (countdownText == nil)
                
                return isPasswordValid && isTimerFinished
            }
            .assign(to: \.value, on: output.isDeleteButtonEnabled)
            .store(in: &cancellables)
        
        input.viewDidAppear
            .sink { [weak self] in
                self?.startTimer()
            }
            .store(in: &cancellables)
        input.viewDidDisappear
            .sink { [weak self] in
                self?.stopTimer()
            }
            .store(in: &cancellables)
        
        input.deleteButtonTapped
            .sink { [weak self] in
                guard let self else{ return }
                self.deleteAccount()
            }
            .store(in: &cancellables)
    }
    
    
    private func deleteAccount() {
        let cleanPassword = input.currentPassword.value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        wipeService.setDeletionPending(true)
        
        output.isLoading.send(true)
        
        Task{
            defer{
                output.isLoading.send(false)
            }
            
            do{
                
                try await authService.reauthenticateUser(currentPassword: cleanPassword)
                
                try await syncService.deleteDataBaseFromFirebase()
                
                try await authService.deleteAccount()
                
                try await wipeService.wipeAllLocalData()
                
                output.isDeleteSuccessful.send()
            }catch{
                output.isLoading.send(false)
                
                output.errorMessage.send(error.localizedDescription)
            }
        }
    }
    
    private func startTimer(){
        guard timerCancellable == nil else { return }
        
        remainingSeconds = 10
        output.countdownText.send("Wait \(remainingSeconds)")
        
        self.timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink{ [weak self] _ in
                guard let self else { return }
                
                self.remainingSeconds -= 1
                
                if self.remainingSeconds > 0 {
                    self.output.countdownText.send("Wait \(self.remainingSeconds)")
                }else{
                    self.output.countdownText.send(nil)
                    self.stopTimer()
                    
                    self.input.currentPassword.send(self.input.currentPassword.value)
                }
            }
            
    }
    
    private func stopTimer(){
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
}
