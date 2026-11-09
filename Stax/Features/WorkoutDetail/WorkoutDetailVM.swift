//
//  WorkoutDetailVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 23.03.26.
//

import Foundation
import Combine

final class WorkoutDetailVM {
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input{
        let viewDidLoad: PassthroughSubject<Void, Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        let screenTitle: CurrentValueSubject<String, Never>
        let summaryData: CurrentValueSubject<DetailSummaryItems?, Never>
        let muscleSplitData: CurrentValueSubject<MuscleSplitItem?, Never>
        let exerciseData: CurrentValueSubject<[ExerciseSectionData]?, Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    //MARK: - Dependencies
    private let workoutID: String
    private let workoutRepo: WorkoutRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(workoutID: String, workoutRepo: WorkoutRepositoryProtocol) {
        self.workoutID = workoutID
        self.workoutRepo = workoutRepo
        
        self.input = .init(viewDidLoad: .init())
        
        self.output = .init(screenTitle: .init(""),
                            summaryData: .init(nil),
                            muscleSplitData: .init(nil),
                            exerciseData: .init(nil)
        )
        
        transform()
        
    }
    
    
    private func transform(){
        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }
                self.getWorkoutDetails()
            }
            .store(in: &cancellables)
    }
    
    
    private func getWorkoutDetails() {
        workoutRepo.fetchWorkouts()

        guard let workout = workoutRepo.getWorkout(by: workoutID) else {
            print("VM cant find workout with id: \(workoutID)")
            return
        }

        output.summaryData.send(createSummaryItem(from: workout))

        let muscleData = MuscleSplitCalculation.calculateMuscleSplit(from: workout)
        if !muscleData.isEmpty {
            output.muscleSplitData.send(MuscleSplitItem(muscleData: muscleData))
        }

        output.exerciseData.send(createExerciseSections(from: workout))
    }

    
    private func createSummaryItem(from workout: WorkoutDomainModel) -> DetailSummaryItems {
        return  DetailSummaryItems(
            id: workout.id,
            workoutName: workout.name ?? "Unknown Workout",
            workoutDescription: workout.workoutDescription,
            durationString: workout.duration.formatDuration(),
            volumeString: workout.volume.formatWeight(),
            setsLabel: "\(workout.sets)",
            caloriesBurnedString: "\(workout.caloriesBurned)kcal")
    }
    
    private func createExerciseSections(from workout: WorkoutDomainModel) -> [ExerciseSectionData] {
        var section: [ExerciseSectionData] = []
        
        for workoutExercise in workout.workoutExercises {
            let id = workoutExercise.id
            let exerciseName = workoutExercise.exercise?.name ?? ""
            let muscleName = workoutExercise.exercise?.targetMuscleGroups?.rawValue
            let exerciseImage = workoutExercise.exercise?.exerciseImage ?? ""
            let exerciseNote = workoutExercise.notes
            
            let headerItem = DetailExerciseHeaderItem(
                id: id,
                exerciseName: exerciseName,
                muscleGroups: muscleName != nil ? [muscleName!] : nil,
                imageURL: exerciseImage,
                note: exerciseNote)
            
            var setRowItems: [DetailSetRowItem] = []
            
            let sortedSets = workoutExercise.workoutSets.sorted {$0.orderIndex < $1.orderIndex }
            
            for (index, set) in sortedSets.enumerated() {
                let setItem = DetailSetRowItem(
                    id: set.id,
                    setIndex: index + 1,
                    weightString: set.weight.formatWeight(),
                    repsString: "\(set.reps)",
                    isCompleted: set.isCompleted)
                setRowItems.append(setItem)
            }
            
            let sectionData = ExerciseSectionData(headerItem: headerItem, items: setRowItems)
            section.append(sectionData)
        }
        
        return section
    }
}
