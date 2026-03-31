//
//  AuthService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.04.26.
//

import Foundation
import CoreData
import FirebaseAuth

protocol AuthServiceProtocol{
    func register(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void)
}

final class AuthService: AuthServiceProtocol {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    
    func register(email: String, password: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
        
    }
}
