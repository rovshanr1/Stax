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
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    //Services
    private let userService: UserServiceProtocol
    private let workoutRepo: WorkoutRepositoryProtocol
    private let chartService: MonthlyChartServiceProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(userService: UserServiceProtocol = UserService(), workoutRepo: WorkoutRepositoryProtocol, chartService: MonthlyChartServiceProtocol = MonthlyChartService()){
        
        self.userService = userService
        self.workoutRepo = workoutRepo
        self.chartService = chartService
        
        self.input = .init( viewDidLoad: .init(),
                            logoutTapped: .init()
        )
        
        self.output = .init( userInfo: .init(nil),
                             userStats: .init(UserStatsModel(workouts: 0, volume: 0.0, duration:  0.0)),
                             chartData: .init([]),
                             profileWorkouts: .init([]),
                             logoutCompleted: .init(),
                             errorMessage: .init(),
                             isLoading: .init(false)
        )
        
        transform()
    }
    
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
}
