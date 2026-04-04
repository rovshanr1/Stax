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
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    //Combine
    private var cancellables = Set<AnyCancellable>()
    
    
    let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        
        
        self.input = .init(viewDidLoad: .init())
        self.output = .init()
        
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
