//
//  LoginVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.04.26.
//

import Foundation
import Combine

final class LoginVM{
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input {
        let viewDidLoad: PassthroughSubject<Void, Never>
        let updateLogin: PassthroughSubject<String, Never>
        let updatePassword: PassthroughSubject<String, Never>
        let didTapLogin: PassthroughSubject<Void, Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        let isLoading: PassthroughSubject<Bool, Never>
        let errorMessage: PassthroughSubject<String, Never>
        let success: PassthroughSubject<Bool, Never>
        let buttonIsEnabled: CurrentValueSubject<Bool, Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    //Combine
    private var cancellables = Set<AnyCancellable>()
    
    
    let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        
        
        self.input = .init(viewDidLoad: .init(),
                           updateLogin: .init(),
                           updatePassword: .init(),
                           didTapLogin: .init()
        )
        self.output = .init(isLoading: .init(),
                            errorMessage: .init(),
                            success: .init(),
                            buttonIsEnabled: .init(false),
        )
        
        transform()
    }
    
    
    private func transform(){
        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }
            }
            .store(in: &cancellables)
    }

    
}
