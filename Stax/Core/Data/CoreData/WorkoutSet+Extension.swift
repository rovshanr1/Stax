//
//  WorkoutSet+Extension.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.03.26.
//

import Foundation
import CoreData

extension WorkoutSet{
    func toDomain() -> WorkoutSetDomainModel {
        return WorkoutSetDomainModel(
            id: self.id?.uuidString ?? UUID().uuidString,
            isCompleted: self.isComplated,
            orderIndex: self.orderIndex,
            previous: self.previous ?? "",
            reps: self.reps,
            restTime: self.restTime,
            weight: self.weight)
    }
}

