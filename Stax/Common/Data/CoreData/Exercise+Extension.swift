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
        ExerciseDomainModel(
            id: self.objectID.uriRepresentation().absoluteString,
            name: self.name ?? "",
            targetMuscleGroups: self.targetMuscle,
            videoURL: self.videoURL ?? ""
        )
    }
}
