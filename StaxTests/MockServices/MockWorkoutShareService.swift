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
    func generateShareText(from workout: Stax.WorkoutDomainModel) -> String {
        return ""
    }
    
}
