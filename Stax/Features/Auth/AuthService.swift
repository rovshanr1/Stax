//
//  AuthService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.04.26.
//

import Foundation
import FirebaseAuth

protocol AuthServiceProtocol{
    func register(name: String, email: String, password: String, profileImage: String?, completion: @escaping (Result<UserModel, Error>) -> Void)
    func login(email: String, password: String, profileImage: String?, completion: @escaping (Result<UserModel, Error>) -> Void)
    func signOut(completion: @escaping (Result<Void, Error>) -> Void)
    
    //async throws method definitions I made for concurrency testing
    func changePassword(currentPassword: String,newPassword: String) async throws
    func changeEmail(email: String) async throws
    func changeUserName(newName: String) async throws
    func deleteAccount(currentPassword: String) async throws
}

final class AuthService: AuthServiceProtocol {
    private let auth = Auth.auth()
    
    func register(name: String, email: String, password: String, profileImage: String?, completion: @escaping (Result<UserModel, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            
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
                let data = UserModel(id: user.uid, name: name , email: email, profileImage: profileImage)
                completion(.success(data))
            }
        }
    }
    
    func login(email: String, password: String, profileImage: String?, completion: @escaping (Result<UserModel, Error>) -> Void){
        auth.signIn(withEmail: email, password: password) { result, error in
            
            
            if let error = error{
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else { return }
            let name = user.displayName ?? "New User"
            
            let model = UserModel(id: user.uid, name: name, email: email, profileImage: profileImage)
            completion(.success(model))
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void){
        do{
            try Auth.auth().signOut()
            completion(.success(()))
        }catch let error {
            completion(.failure(error))
        }
    }
    
    
    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = auth.currentUser, let email = user.email else{
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User Not Found"])
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        try await user.reauthenticate(with: credential)
        
        try await user.updatePassword(to: newPassword)
    }
    
    func changeEmail(email: String) async throws {
        guard let userEmail = auth.currentUser else{
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User Not Found"])
        }
        
        
        try await userEmail.sendEmailVerification(beforeUpdatingEmail: email)
    }
    
    func changeUserName(newName: String) async throws {
        guard let user = auth.currentUser else{
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User Not Found"])
        }
        
        let changeRequset = user.createProfileChangeRequest()
        changeRequset.displayName = newName
        try await changeRequset.commitChanges()
    }
    
    func deleteAccount(currentPassword: String) async throws {
        guard let user = auth.currentUser, let email = user.email else{
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User Not Found"])
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        try await user.reauthenticate(with: credential)
        
        try await user.delete()
    }
    
}
