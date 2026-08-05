//
//  AppDIContainer.swift
//  Stax
//
//  Created by Rovshan Rasulov on 06.05.26.
//

import Foundation
import CoreData

protocol AppDependencies{
    var userManager: UserManager { get }
    var context: NSManagedObjectContext { get }
    var sharedWorkoutRepo: WorkoutRepositoryProtocol { get }
    var sharedFirebaseService: FirebaseSyncService { get }
    
    var dataSeeder: DataSeederProtocol { get }
    var genericWorkoutRepo: DataRepository<Workout> { get }
    var sharedExerciseDefRepo: ExerciseRepositoryProtocol { get }
    var sharedSessionService: SessionServiceProtocol { get }
    var sharedSyncManager: SyncManager {get}
    var shareService: WorkoutShareServiceProtocol { get }
}

final class AppDIContainer: AppDependencies{
    let userManager: UserManager
    
    let persistenceController: PersistenceControllerProtocol
    
    init(userManager: UserManager, persistenceController: PersistenceControllerProtocol) {
        self.userManager = userManager
        self.persistenceController = persistenceController
    }
    
    lazy var context: NSManagedObjectContext = {
        return persistenceController.viewContext
    }()
    
    lazy var genericWorkoutRepo: DataRepository<Workout> = {
        return DataRepository<Workout>(context: context)
    }()
    
    lazy var dataSeeder: DataSeederProtocol = {
        return DataSeeder(context: context)
    }()
    
    lazy var sharedWorkoutRepo: WorkoutRepositoryProtocol = {
        let dataRepository = DataRepository<Workout>(context: context)
        return WorkoutRepository(genericRepository: dataRepository)
    }()
    
    lazy var sharedExerciseDefRepo: ExerciseRepositoryProtocol = {
        let dataRepository = DataRepository<Exercise>(context: context)
        return ExerciseRepository(genericRepository: dataRepository)
    }()
    
    lazy var sharedSessionService: SessionServiceProtocol = {
        let baseExerciseRepo = DataRepository<Exercise>(context: context)
        let exerciseRepo = DataRepository<WorkoutExercise>(context: context)
        let workoutSets = DataRepository<WorkoutSet>(context: context)
        let dataRepository = DataRepository<Workout>(context: context)
        
        return WorkoutSessionRepository(baseExerciseRepo: baseExerciseRepo, exerciseRepo: exerciseRepo, workoutSets: workoutSets, workoutRepo: dataRepository)
    }()
    
    lazy var sharedFirebaseService: FirebaseSyncService = {
        return FirebaseSyncService()
    }()
    
    lazy var sharedSyncManager: SyncManager = {
        let workoutRepo = DataRepository<Workout>(context: context)
        let exerciseRepo = DataRepository<WorkoutExercise>(context: context)
        let setRepo = DataRepository<WorkoutSet>(context: context)
        let exerciseDefRepo = DataRepository<Exercise>(context: context)
        
        return SyncManager(workoutRepo: workoutRepo,
                           exerciseRepo: exerciseRepo,
                           setRepo: setRepo,
                           exercise: exerciseDefRepo
        )
    }()
    
    lazy var shareService: WorkoutShareServiceProtocol = {
        return WorkoutTextShareService()
    }()
}
