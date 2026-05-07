//
//  ExerciseRepository.swift
//  Stax
//
//  Created by Rovshan Rasulov on 08.05.26.
//

import Foundation
import Combine

protocol ExerciseRepositoryProtocol {
    func fetchAll() -> AnyPublisher<[ExerciseDomainModel], Error>
    func search(byName query: String) -> AnyPublisher<[ExerciseDomainModel], Error>
}

final class ExerciseRepository: ExerciseRepositoryProtocol {
    
    private let genericRepository: DataRepository<Exercise>
    
    init(genericRepository: DataRepository<Exercise>) {
        self.genericRepository = genericRepository
    }
    
    func fetchAll() -> AnyPublisher<[ExerciseDomainModel], Error> {
        return genericRepository.fetchAll()
            .map { coreDataExercises in
                coreDataExercises.map { exercise in
                    let muscleGroupEnum = MuscleGroup(rawValue: exercise.targetMuscle ?? "")
                    return ExerciseDomainModel(
                        id: exercise.id?.uuidString ?? UUID().uuidString,
                        name: exercise.name ?? "Unkwnown Exercise",
                        targetMuscleGroups: muscleGroupEnum,
                        videoURL: exercise.videoURL,
                        exerciseImage: exercise.exerciseImage
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    func search(byName query: String) -> AnyPublisher<[ExerciseDomainModel], Error> {
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        
        return genericRepository.search(by: predicate)
            .map { coreDataExercises in
                coreDataExercises.map { exercise in
                    let muscleGroupEnum = MuscleGroup(rawValue: exercise.targetMuscle ?? "")
                    return ExerciseDomainModel(
                        id: exercise.id?.uuidString ?? UUID().uuidString,
                        name: exercise.name ?? "Unkwnown Exercise",
                        targetMuscleGroups: muscleGroupEnum,
                        videoURL: exercise.videoURL,
                        exerciseImage: exercise.exerciseImage
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    
}
