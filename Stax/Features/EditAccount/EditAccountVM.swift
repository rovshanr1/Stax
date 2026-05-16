//
//  EditAccountVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 16.05.26.
//

import Foundation
import Combine

final class EditAccountVM {
    
    struct Input {
        let viewDidLoad: PassthroughSubject<Void, Never>
    }
    
    struct Output {
        
    }
    
    let input: Input
    let output: Output
    
    //Services&Managers
    private let userManager: UserManager
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(userManager: UserManager) {
        self.userManager = userManager
        
        self.input = .init(viewDidLoad: .init())
        
        
        self.output = .init(
            
        )
        
        transform()
    }
    
    private func transform() {
        // The listening (sink) will be done here...
    }
}


