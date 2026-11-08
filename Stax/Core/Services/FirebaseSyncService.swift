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
    func syncWorkoutToCloud(workout: WorkoutDomainModel) async throws
    func deleteWorkoutFromCloud(workoutId: String) async throws
    func fetchInitialWorkoutsFromCloud() async throws -> [WorkoutDomainModel]
    func deleteDataBaseFromFirebase() async throws
}

enum FirebaseSyncError: LocalizedError {
    case notSignedIn
    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "User is not signed in."
        }
    }
}


final class FirebaseSyncService: FirebaseSyncServiceInterface {
    
    private let dataBase = Firestore.firestore()
    
    
    func syncWorkoutToCloud(workout: WorkoutDomainModel) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.notSignedIn
        }
        
        let documentRef = dataBase.collection("users").document(uid).collection("workouts").document(workout.id)
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try documentRef.setData(from: workout, merge: true) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
   func fetchInitialWorkoutsFromCloud() async throws -> [WorkoutDomainModel] {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.notSignedIn
        }
        
        let collectionRef = dataBase.collection("users").document(uid).collection("workouts")
        let snapshot = try await collectionRef.getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: WorkoutDomainModel.self) }
    }
    
    
    
    func deleteWorkoutFromCloud(workoutId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.notSignedIn
        }
        
        let documentRef = dataBase.collection("users").document(uid).collection("workouts").document(workoutId)
        try await documentRef.delete()
    }
    
    
    
    func deleteDataBaseFromFirebase() async throws {
        guard let uid = Auth.auth().currentUser?.uid else{
            let error = NSError(domain: "Auth Error", code: 401, userInfo: [NSLocalizedDescriptionKey: "User do not signin!"])
            throw error
        }
        
        let batch = dataBase.batch()
        
        let userRootRef = dataBase.collection("users").document(uid)
        batch.deleteDocument(userRootRef)
        
        
        let workoutSnapshot = try await userRootRef.collection("workouts").getDocuments()
        
        for document in workoutSnapshot.documents {
            batch.deleteDocument(document.reference)
        }
        
        try await batch.commit()
    }
}

