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
        let viewDidLoad: PassthroughSubject<Void, Never>
    }
    
    struct Output {
        // Output properties...
    }
    
    let input: Input
    let output: Output
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.input = .init(viewDidLoad: .init())
        self.output = .init()
        
        transform()
    }
    
    private func transform() {
        // The listening (sink) will be done here...
    }
}
