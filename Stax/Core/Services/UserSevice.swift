//
//  UserSevice.swift
//  Stax
//
//  Created by Rovshan Rasulov on 07.04.26.
//

import Foundation
import Firebase
import FirebaseAuth

protocol UserServiceProtocol {
    func saveUser(user: UserModel, completion: @escaping (Result<Void, Error>) -> Void)
    func getUser(completion: @escaping (Result<UserModel, Error>) -> Void)
    func updateUserProfileImage(imageUrl: String, completion: @escaping (Result<Void, Error>) -> Void)
    
}

final class UserService: UserServiceProtocol{
    
    private let firestore = Firestore.firestore()
    
    
    func saveUser(user: UserModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        let document = firestore.collection("users").document(user.id)
        
        
        
        let data: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "profileImage": user.profileImage ?? ""
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
        guard let currentUID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            completion(.failure(error))
            return
        }
        
        let userDocument = firestore.collection("users").document(currentUID)
        
        userDocument.getDocument { (document, error) in
            if let error = error{
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else{
                let notFoundError = NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User data not found in Firestore"])
                completion(.failure(notFoundError))
                return
            }
            
            let id = data["id"] as? String ?? currentUID
            let name = data["name"] as? String ?? "Unknown User"
            let email = data["email"] as? String ?? "Unknown Email"
            let image = data["profileImage"] as? String ?? ""
            
            let user = UserModel(id: id, name: name, email: email, profileImage: image)
            completion(.success(user))
        }
    }
    
    func updateUserProfileImage(imageUrl: String, completion: @escaping (Result<Void, Error>) -> Void){
        guard let currentUID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            completion(.failure(error))
            return
        }
        
        let userRef = firestore.collection("users").document(currentUID)
        
        userRef.updateData(["profileImage": imageUrl]){error in
            if let error = error {
                completion(.failure(error))
            }else{
                completion(.success(()))
            }
        }
    }
}
