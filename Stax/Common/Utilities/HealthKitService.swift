//
//  HealthKitService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 22.02.26.
//

import Foundation
import HealthKit

protocol HealthKitServiceInterface{
    var isAvailable: Bool { get }
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void)
    func saveWorkout(duration: TimeInterval, volume: Double, sets: Int, date: Date, completion: @escaping (Bool, Error?) -> Void)
}

final class HealthKitService: HealthKitServiceInterface{
    
    private let healthStore = HKHealthStore()
    
    var isAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization(completion: @escaping (Bool, (any Error)?) -> Void) {
        guard isAvailable else {
            completion(false, NSError(domain: "Stax", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        guard let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false, NSError(domain: "Stax", code: 2, userInfo:[NSLocalizedDescriptionKey: "Active Energy Type not available"]))
            return
        }
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            activeEnergy
        ]
        
        let typesToRead: Set<HKObjectType> = []
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead){success, error in
            DispatchQueue.main.async {
                if success{
                    let workoutType = HKObjectType.workoutType()
                    let status = self.healthStore.authorizationStatus(for: workoutType)
                    
                    if status == .sharingAuthorized{
                        completion(true , nil)
                    }else{
                        completion(false, nil)
                    }
                }else{
                    completion(false, error)
                }
                
            }
            
        }
    }
    
    func saveWorkout(duration: TimeInterval, volume: Double, sets: Int, date: Date, completion: @escaping (Bool, (any Error)?) -> Void) {
        
        //TODO: - Write to healthkit is here
        completion(true, nil)
    }
    
    
}
