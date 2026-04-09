//
//  FirebaseSyncService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 09.04.26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol FirebaseSyncServiceInterface{
    func syncWorkoutToCloud(workout: WorkoutDomainModel, completion: @escaping (Result<Void, Error>) -> Void)
}


final class FirebaseSyncService: FirebaseSyncServiceInterface {
    
    private let dataBase = Firestore.firestore()
    
    
    func syncWorkoutToCloud(workout: WorkoutDomainModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "Auth Error", code: 401, userInfo: [NSLocalizedDescriptionKey: "User do not signin!"])
            completion(.failure(error))
            return
        }
        
        let documentRef = dataBase.collection("users").document(uid).collection("workouts").document(workout.id)
        
        do{
            try documentRef.setData(from: workout, merge: true){ error in
                if let error = error {
                    completion(.failure(error))
                }else{
                    completion(.success(()))
                }
            }
        }catch{
            completion(.failure(error))
        }
        
    }
}

