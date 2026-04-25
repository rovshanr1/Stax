//
//  ProfileVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import Foundation
import Combine

final class ProfileVM{
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input{
        let viewDidLoad: PassthroughSubject<Void, Never>
        let logoutTapped: PassthroughSubject<Void, Never>
        let shareWorkout: PassthroughSubject<String, Never>
        let deleteWokrout: PassthroughSubject<String, Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        let userInfo: CurrentValueSubject<UserModel?, Never>
        let userStats: CurrentValueSubject<UserStatsModel, Never>
        let chartData: CurrentValueSubject<[MonthlyChartData], Never>
        let profileWorkouts: CurrentValueSubject<[WorkoutDomainModel], Never>
        let logoutCompleted: PassthroughSubject<Void, Never>
        let errorMessage: PassthroughSubject<String, Never>
        let isLoading: CurrentValueSubject<Bool, Never>
        let showShareSheet: PassthroughSubject<String, Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    private var cancellables: Set<AnyCancellable> = []
    
    //Services
    private let userService: UserServiceProtocol
    private let workoutRepo: WorkoutRepositoryProtocol
    private let chartService: MonthlyChartServiceProtocol
    private let shareService: WorkoutShareServiceProtocol
    private let syncService: FirebaseSyncServiceInterface
    
    
    
    
    init(userService: UserServiceProtocol = UserService(),
         workoutRepo: WorkoutRepositoryProtocol,
         chartService: MonthlyChartServiceProtocol = MonthlyChartService(),
         shareService: WorkoutShareServiceProtocol = WorkoutTextShareService(),
         syncService: FirebaseSyncServiceInterface = FirebaseSyncService()
    ){
        
        self.userService = userService
        self.workoutRepo = workoutRepo
        self.chartService = chartService
        self.shareService = shareService
        self.syncService = syncService
        
        self.input = .init( viewDidLoad: .init(),
                            logoutTapped: .init(),
                            shareWorkout: .init(),
                            deleteWokrout: .init()
        )
        
        self.output = .init( userInfo: .init(nil),
                             userStats: .init(UserStatsModel(workouts: 0, volume: 0.0, duration:  0.0)),
                             chartData: .init([]),
                             profileWorkouts: .init([]),
                             logoutCompleted: .init(),
                             errorMessage: .init(),
                             isLoading: .init(false),
                             showShareSheet: .init()
        )
        
        transform()
    }
    
    //MARK: - Transform Method
    private func transform(){
        workoutRepo.workoutPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] workouts in
                guard let self else { return }
                
                let count = workouts.count
                let totalVolume = workouts.reduce(0.0) { $0 + $1.volume }
                let totalTime = workouts.reduce(0.0) {$0 + $1.duration}
                
                let stats = UserStatsModel(workouts: count, volume: totalVolume, duration: totalTime)
                self.output.userStats.send(stats)
                
                let chartData = self.chartService.generateChartData(from: workouts)
                self.output.chartData.send(chartData)
                
                let sortedWorkouts = workouts.sorted { $0.date > $1.date }
                let recentWorkouts = Array(sortedWorkouts.prefix(5))
                self.output.profileWorkouts.send(recentWorkouts)
            }
            .store(in: &cancellables)
        
        input.viewDidLoad
            .sink { [weak self] in
                self?.getUser()
                self?.workoutRepo.fetchWorkouts()
            }
            .store(in: &cancellables)

        
        input.shareWorkout
            .sink { [weak self] id in
                guard let self = self, let workoutDomain = self.workoutRepo.getWorkout(by: id) else { return }
                let shareText = self.shareService.generateShareText(from: workoutDomain)
                
                self.output.showShareSheet.send(shareText)
            }
            .store(in: &cancellables)
        
        input.deleteWokrout
            .sink { [weak self] id in
                guard let self else {return}
                workoutRepo.deleteWorkout(by: id)
                self.deleteWorkout(withId: id)
            }
            .store(in: &cancellables)
    }
    
    
    //Helper Methods
    private func getUser(){
        self.output.isLoading.send(true)
        
        userService.getUser { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.output.isLoading.send(false)
                
                switch result{
                case .success(let user):
                    self.output.userInfo.send(user)
                case .failure(let error):
                    self.output.errorMessage.send(error.localizedDescription)
                }
            }
        }
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
