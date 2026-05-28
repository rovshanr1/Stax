//
//  ChangePasswordVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 19.05.26.
//

import Foundation
import Combine

final class ChnagePasswordVM {
    
    struct Input {
        let viewDidLoad: PassthroughSubject<Void, Never>
    }
    
    struct Output {
        
    }
    
    let input: Input
    let output: Output
    
    //Services
    private let authService: AuthServiceProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.input = .init(viewDidLoad: .init())
        self.output = .init()
        
        self.authService = authService
        
        transform()
    }
    
    private func transform() {
        
    }
}

