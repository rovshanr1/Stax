//
//  ProfileVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import Foundation
import Combine

final class ProfileVM{
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input{
        let viewDidLoad: PassthroughSubject<Void, Never>
        let logoutTapped: PassthroughSubject<Void, Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        let userInfo: CurrentValueSubject<UserModel?, Never>
        let totalWorkouts: CurrentValueSubject<Int, Never>
        let logoutComplated: PassthroughSubject<Void, Never>
        let errorMessag: PassthroughSubject<String, Never>
        let isLoading: CurrentValueSubject<Bool, Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    //Services
    private let userService: UserServiceProtocol
    private let workoutRepo: WorkoutRepositoryInterface
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(userService: UserServiceProtocol = UserService(), workoutRepo: WorkoutRepositoryInterface){
        
        self.userService = userService
        self.workoutRepo = workoutRepo
        
        self.input = .init( viewDidLoad: .init(),
                            logoutTapped: .init()
        )
        
        self.output = .init( userInfo: .init(nil),
                             totalWorkouts: .init(0),
                             logoutComplated: .init(),
                             errorMessag: .init(),
                             isLoading: .init(false)
        )
        
        transform()
    }
    
    private func transform(){
        input.viewDidLoad
            .sink { [weak self] in
                self?.getUser()
            }
            .store(in: &cancellables)
    }
    
    
    //Helper Methods
    private func getUser(){
        self.output.isLoading.send(true)
        
        userService.getUser { [weak self] result in
            guard let self else { return }
        
            DispatchQueue.main.async {
                self.output.isLoading.send(false)
                
                switch result{
                case .success(let user):
                    self.output.userInfo.send(user)
                case .failure(let error):
                    self.output.errorMessag.send(error.localizedDescription)
                }
            }
        }
    }
}
