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
            activeEnergy,
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
        //Date calculation
        let endDate = date
        let startDate = endDate.addingTimeInterval( -duration )
        
        //HKConfiguration
        let hkConfiguration = HKWorkoutConfiguration()
        hkConfiguration.activityType = .traditionalStrengthTraining
        hkConfiguration.locationType = .indoor
        
        let hKWorkoutBuilder = HKWorkoutBuilder(healthStore: healthStore, configuration: hkConfiguration, device: .local())
        
        //Begin Collection
        hKWorkoutBuilder.beginCollection(withStart: startDate) { (success, error) in
            guard success else{
                completion(false,error)
                return
            }
            
            // Calorie sample
            let durationInMinutes = duration / 60.0
            let estimatedCalories = durationInMinutes * 5.0
            
            guard let activeEnergyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
                completion(false, NSError(domain: "Stax", code: 3, userInfo: [NSLocalizedDescriptionKey: "Type Error"]))
                return
            }
            let energyBurnedQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: estimatedCalories)
            
            
            let energySample = HKQuantitySample(
                type: activeEnergyBurnedType,
                quantity: energyBurnedQuantity,
                start: startDate,
                end: endDate
            )
            
            
            // Metadata
            let metadata: [String: Any] = [
                HKMetadataKeyIndoorWorkout: true,
                "Total Volume (kg)": volume,
                "Total Set": sets
            ]
            
            hKWorkoutBuilder.addMetadata(metadata) {(success, error ) in
                guard success else{
                    completion(false, error)
                    return
                }
                
                hKWorkoutBuilder.add([energySample]) {(success, error) in
                    guard success else{
                        completion(false, error)
                        return
                    }
                    
                    hKWorkoutBuilder.endCollection(withEnd: endDate) {(success, error) in
                        guard success else{
                            completion(false, error)
                            return
                        }
                    }
                    
                    hKWorkoutBuilder.finishWorkout { (workout, error) in
                        if workout != nil {
                            print("Calorie: \(estimatedCalories)")
                            completion(true, nil)
                        }else{
                            print("Builder finish workout error: \(error?.localizedDescription ?? "Unknown error")")
                            completion(false, error)
                        }
                    }
                }
            }
        }
    }
}
