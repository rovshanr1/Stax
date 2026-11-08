//
//  WorkoutSummaryViewModel.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.01.26.
//

import Foundation
import Combine

final class WorkoutSummaryViewModel {
    //MARK: - I/O Structs
    struct Input {
        let viewDidLoad: PassthroughSubject<Void, Never>
        let updateTitle: PassthroughSubject<String, Never>
        let updateDescription: PassthroughSubject<String, Never>
        let saveWorkout: PassthroughSubject<Void, Never>
        let toggleHealthKitSync: PassthroughSubject<Bool, Never>
        let discardWorkout: PassthroughSubject<Void, Never>
    }
    
    struct Output {
        let defaultTitle: CurrentValueSubject<String, Never>
        let finished: PassthroughSubject<Void, Never>
        let workoutStats: PassthroughSubject<WorkoutSummaryPresentation, Never>
        let isHealthKitSyncEnabled: CurrentValueSubject<Bool, Never>
        let syncWarning: PassthroughSubject<String, Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    private let workoutRepository: WorkoutRepositoryProtocol
    private let stats: WorkoutStats
    private let workoutID: String
    private let workoutDate: Date
    
    private var pendingTitle: String
    private var pendingDescription: String = ""
    
    //Preference/External Services
    private var preferencesService: AppPreferencesServiceInterface
    private let healthKitService: HealthKitServiceInterface
    private let syncService: FirebaseSyncServiceInterface
    
    private var cancellables: Set<AnyCancellable> = []
    
    let emojis = ["🔥", "💪", "🏋️‍♂️", "🏃‍♂️", "🦍", "⚡️"]
    
    init(workoutID: String,
         workoutRepository: WorkoutRepositoryProtocol,
         stats: WorkoutStats,
         preferancesService: AppPreferencesServiceInterface = AppPreferencesService(),
         healthKitService: HealthKitServiceInterface = HealthKitService(),
         syncService: FirebaseSyncServiceInterface = FirebaseSyncService()
    ) {
        self.workoutID = workoutID
        self.workoutRepository = workoutRepository
        self.stats = stats
        self.preferencesService = preferancesService
        self.healthKitService = healthKitService
        self.syncService = syncService
        
        let existingWorkout = workoutRepository.fetchWorkoutDetails(by: workoutID)
        self.workoutDate = existingWorkout?.date ?? Date()
        self.pendingTitle = existingWorkout?.name ?? ""
        
        self.input = Input(
            viewDidLoad: .init(),
            updateTitle: .init(),
            updateDescription: .init(),
            saveWorkout: .init(),
            toggleHealthKitSync: .init(),
            discardWorkout: .init()
        )
        
        self.output = Output(
            defaultTitle: .init(""),
            finished: .init(),
            workoutStats: .init(),
            isHealthKitSyncEnabled: .init(preferencesService.isHealthKitSyncEnabled),
            syncWarning: .init()
        )
        
        transform()
    }
    
    private func transform() {
        input.viewDidLoad
            .sink { [weak self] in
                self?.setupInitialData()
            }
            .store(in: &cancellables)
        
        input.saveWorkout
            .sink { [weak self] in
                self?.performSave()
            }
            .store(in: &cancellables)
        
        input.updateTitle
            .sink { [weak self] newTitle in
                self?.pendingTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .store(in: &cancellables)
        
        input.updateDescription
            .sink { [weak self] newDescription in
                self?.pendingDescription = newDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .store(in: &cancellables)
        
        input.toggleHealthKitSync
            .sink { [weak self] isEnabled in
                self?.handleHealthKitToggle(isEnabled)
            }
            .store(in: &cancellables)
        
        input.discardWorkout
            .sink { [weak self] in
                guard let self else { return }
                self.workoutRepository.deleteWorkout(by: self.workoutID)
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Initial Data
    private func setupInitialData() {
        let randomEmoji = emojis.randomElement() ?? "💪"
        let defaultName = "\(workoutDate.dayName()) Workout\(randomEmoji)"
        let currentTitle = pendingTitle.isEmpty ? defaultName : pendingTitle
        
        output.defaultTitle.send(currentTitle)
        
        let presentation = WorkoutSummaryPresentation(
            duration: stats.duration.formatDuration(),
            volume: stats.volume.formatWeight(),
            sets: stats.totalSets,
            date: workoutDate
        )
        
        output.workoutStats.send(presentation)
    }
    
    //MARK: - Save Flow
    private func performSave() {
        Task { [weak self] in
            await self?.saveWorkoutSequentially()
        }
    }
    
    private func saveWorkoutSequentially() async {
        let finalTitle = pendingTitle.isEmpty ? output.defaultTitle.value : pendingTitle
        
        let savedWorkout: WorkoutDomainModel
        do {
            savedWorkout = try await workoutRepository.finalizeWorkout(
                id: workoutID, title: finalTitle, description: pendingDescription, stats: stats
            )
        } catch {
            print("Failed to save workout: \(error)")
            output.syncWarning.send("Workout could not be saved. Please try again.")
            return
        }
        
        await syncToCloudIfPossible(workout: savedWorkout)
        await syncToHealthKitIfEnabled()
        
        output.finished.send()
    }
    
    private func syncToCloudIfPossible(workout: WorkoutDomainModel) async {
        do {
            try await syncService.syncWorkoutToCloud(workout: workout)
        } catch {
            print("Firebase sync failed: \(error)")
            output.syncWarning.send("Workout saved locally, but cloud sync failed.")
        }
    }
    
    private func syncToHealthKitIfEnabled() async {
        guard preferencesService.isHealthKitSyncEnabled else { return }
        
        do {
            try await healthKitService.saveWorkout(
                duration: stats.duration, volume: stats.volume, sets: stats.totalSets,
                calories: stats.caloriesBurned ?? 0, date: workoutDate
            )
        } catch {
            print("HealthKit sync failed: \(error)")
            output.syncWarning.send("Workout saved, but Apple Health sync failed.")
        }
    }
    
    //MARK: - HealthKit Toggle
    private func handleHealthKitToggle(_ isEnabled: Bool) {
        guard isEnabled else {
            preferencesService.isHealthKitSyncEnabled = false
            output.isHealthKitSyncEnabled.send(false)
            return
        }
        
        Task { [weak self] in
            guard let self else { return }
            let granted = await self.healthKitService.requestAuthorization()
            self.preferencesService.isHealthKitSyncEnabled = granted
            self.output.isHealthKitSyncEnabled.send(granted)
        }
    }
}
