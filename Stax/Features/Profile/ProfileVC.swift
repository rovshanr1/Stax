//
//  ProfileVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit
import SwiftUI
import Combine

class ProfileVC: UIViewController {
    //MARK: - Diffable Data Source
    nonisolated enum Section: Hashable, Sendable {
        case profile
        case charts
        case workouts
    }
    
    nonisolated enum RowItem: Hashable, Sendable {
        case profileInfo(UserModel)
        case chart([MonthlyChartData])
        case workout(WorkoutDomainModel)
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, RowItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, RowItem>
    
    //Closures
    var didSendEventClosure: ((ProfileEvent) -> Void)?
    
    //Private properties
    private let contentView = ProfileUIView()
    private let viewModel: ProfileVM
    
    private var dataSource: DataSource!
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ProfileVM) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLeftAlignedNavigationTitle(with: "Profile")
        
        configureDataSource()
        bindViewModel()
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    deinit{
        print("Deninited Profile")
    }
    
    //MARK: - DataSource Configuration
    private func configureDataSource() {
        contentView.collectionView.delegate = self
        
        let profileInfoRegistration = UICollectionView.CellRegistration<ProfileInfoCell, UserModel> {[weak self] (cell, _, userModel) in
            let isLoading = self?.viewModel.output.isLoading.value ?? false
            
            let stats = self?.viewModel.output.userStats.value
            let totalWokrouts = stats?.workouts ?? 0
            let volumeText = stats?.volume ?? 0
            let durationText = stats?.duration ?? 0
            
            cell.configurationCell(with: userModel, isLoading: isLoading, totalWorkouts: totalWokrouts, totalVolumes: volumeText, totalWorkoutTime: durationText)
        }
        
        let monthlyChartregistration = UICollectionView.CellRegistration<UICollectionViewCell, [MonthlyChartData]>{(cell, _, item) in
            cell.contentConfiguration = UIHostingConfiguration{
                MonthlyChart(data: item)
            }
            
            var background = UIBackgroundConfiguration.listCell()
            background.cornerRadius = 12
            cell.backgroundConfiguration = background
        }
        
        let profileWorkoutsRegistration = UICollectionView.CellRegistration<ProfileWorkoutsCell, WorkoutDomainModel>  { (cell, _, workoutsData) in
            cell.configureProfileWorkoutCell(with: workoutsData)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<SectionHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            
            
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            
            if section == .workouts {
                supplementaryView.titleLabel.text = "Workouts"
            } else {
                supplementaryView.titleLabel.text = nil
            }
        }
        
        dataSource = DataSource(collectionView: contentView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier{
                
            case .profileInfo(let userData):
                return collectionView.dequeueConfiguredReusableCell(using: profileInfoRegistration, for: indexPath, item: userData)
            case .chart(let chartDataArry):
                return collectionView.dequeueConfiguredReusableCell(using: monthlyChartregistration, for: indexPath, item: chartDataArry)
            case .workout(let workoutsData):
                return collectionView.dequeueConfiguredReusableCell(using: profileWorkoutsRegistration, for: indexPath, item: workoutsData)
            }
        })
        
        dataSource.supplementaryViewProvider = { (collectionView, _, indexPath) in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    //MARK: - ViewModel configuration
    private func bindViewModel(){
        
        Publishers.CombineLatest3(
            viewModel.output.userInfo,
            viewModel.output.chartData,
            viewModel.output.profileWorkouts
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] ( userData, chartData, profileWorkoutsData) in
            guard let self = self, let userData = userData else { return }
            
            self.updateSnapshot(with: userData, chartData: chartData, profileWorkouts: profileWorkoutsData)
        }
        .store(in: &cancellables)
        
        viewModel.output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading{
                    self.showLoadingSnapshot()
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.userStats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else {return}
                guard let currentUser = self.viewModel.output.userInfo.value else { return }
                
                var snapshot = self.dataSource.snapshot()
                let itemToReload  = RowItem.profileInfo(currentUser)
                
                if snapshot.indexOfItem(itemToReload) != nil{
                    snapshot.reloadItems([itemToReload])
                    self.dataSource.apply(snapshot, animatingDifferences: false)
                }
            }
            .store(in: &cancellables)
        
        viewModel.input.viewDidLoad.send()
    }
    
    //MARK: - Snapshot configuration
    private func showLoadingSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.profile])
        
        
        let dummyUser = UserModel(id: "dummy", name: "", email: "", profileImage: nil)
        snapshot.appendItems([.profileInfo(dummyUser)])
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func updateSnapshot(with profileInfo: UserModel, chartData: [MonthlyChartData], profileWorkouts: [WorkoutDomainModel]){
        var snapshot = Snapshot()
        
        snapshot.appendSections([.profile, .charts, .workouts])
        
        snapshot.appendItems([.profileInfo(profileInfo)], toSection: .profile)
        snapshot.appendItems([.chart(chartData)], toSection: .charts)
        
        let workoutItems = profileWorkouts.map {RowItem.workout($0)}
        snapshot.appendItems(workoutItems, toSection: .workouts)
        
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

//MARK: - CollectionView delegate
extension ProfileVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return true }
        switch item{
        case .profileInfo:
            return false
        case .chart:
            return false
        case .workout:
            return true
        }
    }
}
