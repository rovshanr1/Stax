//
//  UserSevice.swift
//  Stax
//
//  Created by Rovshan Rasulov on 07.04.26.
//

import Foundation
import Firebase

protocol UserServiceProtocol {
    func saveUser(user: UserModel, completion: @escaping (Result<Void, Error>) -> Void)
    func getUser(completion: @escaping (Result<UserModel, Error>) -> Void)
}

final class UserService: UserServiceProtocol{
    
    private let firestore = Firestore.firestore()
    
    
    func saveUser(user: UserModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        let document = firestore.collection("users").document(user.id)
        
        let data: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "email": user.email,
        ]
        
        document.setData(data, merge: true) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getUser(completion: @escaping (Result<UserModel, Error>) -> Void) {
        
    }
}
