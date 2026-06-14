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
    }
    
    struct Output {
        let isDeleteButtonEnabled: CurrentValueSubject<Bool, Never>
        let isLoading: CurrentValueSubject<Bool, Never>
        let errorMessage: PassthroughSubject<String, Never>
        let isDeleteSuccessful: PassthroughSubject<Void, Never>
    }
    
    let input: Input
    let output: Output
    
    //MARK: - Private Properties
    
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
                           deleteButtonTapped: .init()
        )
        
        self.output = .init(isDeleteButtonEnabled: .init(false),
                            isLoading: .init(false),
                            errorMessage: .init(),
                            isDeleteSuccessful: .init()
        )
        
        transform()
    }
    
    private func transform() {
        input.currentPassword
            .map {password in
                return !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .assign(to: \.value, on: output.isDeleteButtonEnabled)
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
    
}
