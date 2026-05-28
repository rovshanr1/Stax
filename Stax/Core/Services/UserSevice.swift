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
    
    //async throws method definitions I made for concurrency testing
    func updateUserProfile(name: String, bio: String, imageURL: String?) async throws
    func updateEmail(email: String) async throws
    func updateUserName(name: String) async throws
}

final class UserService: UserServiceProtocol{
    
    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()
    
    
    func saveUser(user: UserModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        let document = firestore.collection("users").document(user.id)
        
        
        
        let data: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "profileImage": user.profileImage ?? "",
            "bio": user.bio ?? ""
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
            let bio = data["bio"] as? String ?? ""
            
            let user = UserModel(id: id, name: name, email: email, profileImage: image, bio: bio)
            completion(.success(user))
        }
    }
    
    func updateUserProfile(name: String, bio: String, imageURL: String?) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let userRef = firestore.collection("users").document(currentUID)
        
        var updateData: [String: Any] = [
            "name" : name,
            "bio" : bio
        ]
        
        if let newImageURl = imageURL{
            updateData["profileImage"] = newImageURl
        }
        
        try await userRef.updateData(updateData)
    }
    
    
    
    func updateEmail(email: String) async throws {
        guard let currentUID = auth.currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            
        }
        
        let userRef = firestore.collection("users").document(currentUID)
        
        try await userRef.updateData(["email": email])
        
    }
    
    func updateUserName(name: String) async throws {
        guard let currentUID = auth.currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let userRef = firestore.collection("users").document(currentUID)
        
        try await userRef.updateData(["name": name])
    }
}
