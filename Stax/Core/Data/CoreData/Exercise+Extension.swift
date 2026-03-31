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
        let safeMusleGroup = MuscleGroup(rawValue: rawMuscleString) ?? .other
        
       return ExerciseDomainModel(
            id: self.objectID.uriRepresentation().absoluteString,
            name: self.name ?? "",
            targetMuscleGroups: safeMusleGroup,
            videoURL: self.videoURL ?? ""
        )
    }
}
