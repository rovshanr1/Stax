//
//  AuthService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.04.26.
//

import Foundation
import FirebaseAuth

protocol AuthServiceProtocol{
    func register(name: String, email: String, password: String, completion: @escaping (Result<UserModel, Error>) -> Void)
    func login(email: String, password: String, completion: @escaping (Result<UserModel, Error>) -> Void)
}

final class AuthService: AuthServiceProtocol {
    
    private let auth = Auth.auth()
    
    func register(name: String, email: String, password: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) {[weak self] result, error in
            guard let self else { return }
            
           if let error = error {
               completion(.failure(error))
               return
            }
            
            guard let user = result?.user else { return }
            
            let changeRequest = result?.user.createProfileChangeRequest()
            changeRequest?.displayName = name
            
            changeRequest?.commitChanges() { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let data = UserModel(id: user.uid, name: name , email: email)
                completion(.success(data))
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<UserModel, Error>) -> Void){
        auth.signIn(withEmail: email, password: password) {[weak self] result, error in
            guard let self else { return }
            
            if let error = error{
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else { return }
            let name = user.displayName ?? "New User"
            
            let model = UserModel(id: user.uid, name: name, email: email)
            completion(.success(model))
        }
    }
}
