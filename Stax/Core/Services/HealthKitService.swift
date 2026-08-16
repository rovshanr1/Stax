//
//  HealthKitService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 22.02.26.
//

import Foundation
import HealthKit

protocol HealthKitServiceInterface {
    var isAvailable: Bool { get }
    func requestAuthorization() async -> Bool
    func saveWorkout(duration: TimeInterval, volume: Double, sets: Int, calories: Double, date: Date) async throws
}

enum HealthKitServiceError: LocalizedError {
    case missingType(String)
    case operationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .missingType(let name): return "\(name) type not available"
        case .operationFailed(let step): return "HealthKit \(step) failed"
        }
    }
}

final class HealthKitService: HealthKitServiceInterface{
    
    private let healthStore = HKHealthStore()
    
    
    var isAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        
        guard let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return false
        }
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            activeEnergy
        ]
        let typesToRead: Set<HKObjectType> = []
        
        let granted: Bool = await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, _ in
                continuation.resume(returning: success)
            }
        }
        
        guard granted else { return false }
        
        let status = healthStore.authorizationStatus(for: HKObjectType.workoutType())
        return status == .sharingAuthorized
    }
    
    func saveWorkout(duration: TimeInterval, volume: Double, sets: Int, calories: Double, date: Date) async throws {
        let endDate = date
        let startDate = endDate.addingTimeInterval(-duration)
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())
        
        try await beginCollection(builder: builder, startDate: startDate)
        
        guard let activeEnergyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw HealthKitServiceError.missingType("Active Energy")
        }
        
        let energySample = HKQuantitySample(
            type: activeEnergyBurnedType,
            quantity: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
            start: startDate,
            end: endDate
        )
        
        let metadata: [String: Any] = [
            HKMetadataKeyIndoorWorkout: true,
            "Total Volume (kg)": volume,
            "Total Set": sets
        ]
        
        try await addMetadata(builder: builder, metadata: metadata)
        try await addSamples(builder: builder, samples: [energySample])
        try await endCollection(builder: builder, endDate: endDate)
        try await finishWorkout(builder: builder)
    }
    
    //MARK: - Continuation-wrapped builder
    private func beginCollection(builder: HKWorkoutBuilder, startDate: Date) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            builder.beginCollection(withStart: startDate) { success, error in
                success ? continuation.resume() : continuation.resume(throwing: error ?? HealthKitServiceError.operationFailed("beginCollection"))
            }
        }
    }
    
    private func addMetadata(builder: HKWorkoutBuilder, metadata: [String: Any]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            builder.addMetadata(metadata) { success, error in
                success ? continuation.resume() : continuation.resume(throwing: error ?? HealthKitServiceError.operationFailed("addMetadata"))
            }
        }
    }
    
    private func addSamples(builder: HKWorkoutBuilder, samples: [HKSample]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            builder.add(samples) { success, error in
                success ? continuation.resume() : continuation.resume(throwing: error ?? HealthKitServiceError.operationFailed("add samples"))
            }
        }
    }
    
    private func endCollection(builder: HKWorkoutBuilder, endDate: Date) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            builder.endCollection(withEnd: endDate) { success, error in
                success ? continuation.resume() : continuation.resume(throwing: error ?? HealthKitServiceError.operationFailed("endCollection"))
            }
        }
    }
    
    private func finishWorkout(builder: HKWorkoutBuilder) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            builder.finishWorkout { workout, error in
                if workout != nil {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? HealthKitServiceError.operationFailed("finishWorkout"))
                }
            }
        }
    }
}
