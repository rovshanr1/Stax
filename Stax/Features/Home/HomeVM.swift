//
//  HomeVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import Foundation
import Combine

final class HomeVM {
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input{
        let viewDidLoad: PassthroughSubject<Void, Never>
        let deleteWorkout: PassthroughSubject<String, Never>
        let shareWorkout: PassthroughSubject<String, Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        let workouts: CurrentValueSubject<[HomeWorkoutPresentationItem], Never>
        let showShareSheet: PassthroughSubject<String, Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    //Repositorys & Services
    private let workoutRepo: WorkoutRepositoryProtocol
    private let shareService: WorkoutShareServiceProtocol
    private let syncService: FirebaseSyncServiceInterface

    
    //Combine
    private var cancellables = Set<AnyCancellable>()
    
    init(workoutRepo: WorkoutRepositoryProtocol, shareService: WorkoutShareServiceProtocol, synService: FirebaseSyncServiceInterface = FirebaseSyncService()){
        self.workoutRepo = workoutRepo
        self.shareService = shareService
        self.syncService = synService
        
        self.input = .init(viewDidLoad: .init(),
                           deleteWorkout: .init(),
                           shareWorkout: .init()
        )
        self.output = .init(workouts: .init([]),
                            showShareSheet: .init()
            
        )
        
        transform()
        bindRepository()
    }
    
    //MARK: - Transform Method
    private func transform(){
        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }
                self.workoutRepo.fetchWorkouts()
            }
            .store(in: &cancellables)
        input.deleteWorkout
            .sink { [weak self] id in
                guard let self else { return }
                workoutRepo.deleteWorkout(by: id)
                
                self.deleteWorkout(withId: id)
                
            }
            .store(in: &cancellables)
        input.shareWorkout
            .sink { [weak self] id  in
                guard let self else { return }
                guard  let workoutDomain = self.workoutRepo.getWorkout(by: id) else {return}
                let shareText = self.shareService.generateShareText(from: workoutDomain)
                self.output.showShareSheet.send(shareText)
            }
            .store(in: &cancellables)
    }
    
    private func bindRepository(){
        workoutRepo.workoutPublisher
            .map {domainModels in
                
                return domainModels.map { workout in
                    HomeWorkoutPresentationItem(
                        id: workout.id,
                        title: workout.name,
                        dateString: DateFormatter.localizedString(from: workout.date, dateStyle: .medium, timeStyle: .none),
                        time: workout.duration.formatDuration(),
                        volume: workout.volume.formatWeight(),
                        exerciseSummar: self.generateExerciseSummary(for: workout.workoutExercises),
                        moreText: workout.workoutExercises.count > 3 ? "+ \(workout.workoutExercises.count - 3) more exercises" : nil
                    )
                }
            }
            .sink { [weak self] presentationItems in
                self?.output.workouts.send(presentationItems)
            }
            .store(in: &cancellables)
    }
    
    private func generateExerciseSummary(for exercises: [WorkoutExerciseDomainModel]) -> [ExerciseSummaryItem]{
        let topExercises = exercises.prefix(3)
        var summaryItems: [ExerciseSummaryItem] = []
        
        for workoutExercise in topExercises{
            let exerciseName = workoutExercise.exercise?.name ?? "Unknown Exercise"
            let activeSetsCount = workoutExercise.workoutSets.count
            let title = "\(activeSetsCount) sets of \(exerciseName)"
            
            let item = ExerciseSummaryItem(exerciseName: title, imageURl: nil)
            summaryItems.append(item)
        }
 
        return summaryItems
    }
    
 
    
    private func formatDuration(seconds: Double) -> String{
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours == 0{
            return String(format: "%02dmin %02dsec", minutes, seconds)
        }else{
            return String(format: "%02dh %02dmin %02dsec", hours, minutes, seconds)
        }
    }
 
    
    private func getShareText(for id: String) -> String{
        guard let workout = workoutRepo.getWorkout(by: id) else { return "Workout not found"}
        
        return shareService.generateShareText(from: workout)
    }
    
    private func deleteWorkout(withId id: String){
        
        syncService.deleteWorkoutFromCloud(workoutId: id){ result in
            switch result {
            case .success:
                print("workout deleted: \(id)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
