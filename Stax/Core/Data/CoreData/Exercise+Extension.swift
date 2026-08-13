//
//  Exercise+Extension.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.03.26.
//

import Foundation
import CoreData

extension Exercise{
    func toDomain() -> ExerciseDomainModel {
        
        let rawMuscleString = self.targetMuscle ?? ""
        let rawTargetString = self.type ?? ""
        
        let safeMusleGroup = MuscleGroup(rawValue: rawMuscleString) ?? .other
        let exerciseType = ExerciseType(rawValue: rawTargetString) ?? .weighted

        return ExerciseDomainModel(
            id: self.id?.uuidString ?? UUID().uuidString,
            name: self.name ?? "",
            targetMuscleGroups: safeMusleGroup,
            videoURL: self.videoURL ?? "",
            exerciseImage: self.exerciseImage ?? "",
            type: exerciseType
        )
    }
}
