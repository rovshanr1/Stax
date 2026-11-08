//
//  MockWorkoutShareService.swift
//  StaxTests
//
//  Created by Rovshan Rasulov on 12.06.26.
//

import Foundation
@testable import Stax
import Combine


final class MockWorkoutShareService: WorkoutShareServiceProtocol{
    var capturedWorkoutToShare: Stax.WorkoutDomainModel?
    var stubbedShareText: String = "heute habe ich seher gut Sport gemacht"
    
    
    
    func generateShareText(from workout: Stax.WorkoutDomainModel) -> String {
        self.capturedWorkoutToShare = workout
        return stubbedShareText
    }
    
}
