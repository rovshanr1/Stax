//
//  SignUpVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.04.26.
//

import Foundation

final class SignUpVM{
    let authService: AuthServiceProtocol
    
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
}
