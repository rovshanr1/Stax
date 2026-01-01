//
//  WorkoutSessionVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.12.25.
//

import UIKit
import Combine
import CoreData

final class WorkoutSessionViewModel: NSObject{
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input{
        let viewDidLoad: PassthroughSubject<Void, Never>
        let didTapFinish: PassthroughSubject<Void, Never>
        let didTapCancel: PassthroughSubject<Void, Never>
        let didTapCheckout: PassthroughSubject<Void, Never>
        let addExercise: PassthroughSubject<Exercise, Never>
        let addSet: PassthroughSubject<WorkoutSet, Never>
        let updateExerciseNote: PassthroughSubject<(NSManagedObjectID, String), Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        let timerSubject: CurrentValueSubject<String, Never>
        let dismissEvent: PassthroughSubject<Void, Never>
        let exercises: CurrentValueSubject<[WorkoutExercise], Never>
        let workoutSets: CurrentValueSubject<[WorkoutSet], Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    private let exerciseRepo: DataRepository<WorkoutExercise>
    private let workoutSets: DataRepository<WorkoutSet>
    
    private let workoutRepo: DataRepository<Workout>
    public private(set) var currentWorkout: Workout?
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var secondsElapsed: Int = 0
    private var frc: NSFetchedResultsController<WorkoutExercise>?
    
    
    
    
    //MARK: - Initializer
    init(workoutRepo: DataRepository<Workout>, exerciseRepo: DataRepository<WorkoutExercise>, workoutSets: DataRepository<WorkoutSet>) {
        self.workoutRepo = workoutRepo
        self.exerciseRepo = exerciseRepo
        self.workoutSets = workoutSets
        
        self.input = .init(viewDidLoad: .init(),
                           didTapFinish: .init(),
                           didTapCancel: .init(),
                           didTapCheckout: .init(),
                           addExercise: .init(),
                           addSet: .init(),
                           updateExerciseNote: .init(),
        )
        
        self.output = .init(timerSubject: .init("0s"),
                            dismissEvent: .init(),
                            exercises: .init([]),
                            workoutSets: .init([])
                            
        )
        
        super.init()
        transform()
    }
    
    
    //MARK: - Transform method
    private func transform() {
        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }
                self.startTimer( )
                
                self.currentWorkout = self.workoutRepo.create()
                self.currentWorkout?.date = Date()
                self.currentWorkout?.id = UUID()
                
                self.startFetchExercises()
            }
            .store(in: &cancellables)
        
        input.didTapCheckout
            .sink { [weak self] in
                guard let self else { return }
                
                print(self.input.didTapCheckout)
                
            }
            .store(in: &cancellables)
        
        input.didTapFinish
            .sink { [weak self] workout in
                guard let self, let workout = self.currentWorkout else {return}
                
                workout.duration = Int32(self.secondsElapsed)
                
                self.workoutRepo.save()
                    .sink(receiveCompletion: { complation in
                        if case .failure(let failure) = complation {
                            print(failure)
                        }
                    }, receiveValue: { _ in
                        print("Workout Saved: \(workout.duration) seconds")
                        self.output.dismissEvent.send()
                    })
                    .store(in: &self.cancellables)
                
            }
            .store(in: &cancellables)
        
        input.didTapCancel
            .sink { [weak self] in
                guard let self else {return}
                self.stopTimer()
                
                if let workoutToDelete = self.currentWorkout {
                    self.workoutRepo.delete(workoutToDelete)
                        .sink(receiveCompletion: { _ in}, receiveValue: {_ in})
                        .store(in: &cancellables)
                }
                self.output.dismissEvent.send()
            }
            .store(in: &cancellables)
        
        input.addExercise
            .sink { [weak self] exercise in
                self?.addExercise(exercise)
            }
            .store(in: &cancellables)
        
        input.updateExerciseNote
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] (objectId, noteText) in
                
                self?.updateNote(for: objectId, text: noteText)
            }
            .store(in: &cancellables)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            self.secondsElapsed += 1
            let formatted = self.formatTime(self.secondsElapsed)
            
            self.output.timerSubject.send(formatted)
        })
    }
    
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%2dh %2dm %2ds", hours, minutes, seconds)
        }else if minutes > 0 {
            return String(format: "%2dm %2ds", minutes, seconds)
        }else {
            return String(format: "%2ds", seconds)
        }
    }
    
    private func addExercise(_ exerciseDefinition: Exercise) {
        guard let workout = currentWorkout else { return }
        
        let newSet = exerciseRepo.create()
        
        newSet.exercise = exerciseDefinition
        newSet.workout = workout
        
        let newIndex = output.exercises.value.count
        newSet.orderIndex = Int16(newIndex)
        
        
        exerciseRepo.save()
            .sink(receiveCompletion: {_ in}) { _ in
                print("Exercise added")
            }
            .store(in: &cancellables)
    }
    
    private func updateNote(for id: NSManagedObjectID, text: String){
        exerciseRepo.update(id: id) { exercise in
            exercise.note = text
        }
        .sink { complation in
            if case .failure(let error) = complation {
                print("Note updates error: \(error)")
            }
        } receiveValue: {
            print("Note updated successfully for id: \(id)")
        }
        .store(in: &cancellables)
    }
    
    private func startFetchExercises() {
        guard let workout = currentWorkout else { return }
        
        let predicate = NSPredicate(format: "workout == %@", workout)
        
        let sort = NSSortDescriptor(key: "orderIndex", ascending: true)
        
        frc = exerciseRepo.makeFetchResultsController(sortDescriptors: [sort], predicate: predicate)
        frc?.delegate = self
        
        do {
            try frc?.performFetch()
            
            output.exercises.send(frc?.fetchedObjects ?? [])
        }catch {
            print("FRC Error: \(error)")
        }
    }
}

//MARK: - FRC Delegate Extension
extension WorkoutSessionViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let exercise = controller.fetchedObjects as? [WorkoutExercise] else { return }
        
        output.exercises.send(exercise)
    }
}
