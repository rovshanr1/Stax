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
    func deleteWorkoutFromCloud(workoutId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchInitialWorkoutsFromCloud(completion: @escaping (Result<[WorkoutDomainModel], Error>) -> Void)
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
    
    func deleteWorkoutFromCloud(workoutId: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "Auth Error", code: 401, userInfo: [NSLocalizedDescriptionKey: "User do not signin!"])
            completion(.failure(error))
            return
        }
        
        let documentRef = dataBase.collection("users").document(uid).collection("workouts").document(workoutId)
        
        documentRef.delete() { error in
            if let error = error {
                completion(.failure(error))
            }else{
                completion(.success(()))
            }
        }
    }
    
    func fetchInitialWorkoutsFromCloud(completion: @escaping (Result<[WorkoutDomainModel], Error>) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "Auth Error", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not signed in!"])
            completion(.failure(error))
            return
        }
        
        let collectionRef = dataBase.collection("users").document(uid).collection("workouts")
        
        collectionRef.getDocuments { snapshot, error in
            
            Task{@MainActor in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                
                let workouts = documents.compactMap { try? $0.data(as: WorkoutDomainModel.self) }
                
                completion(.success(workouts))
            }
           
        }
    }
}

