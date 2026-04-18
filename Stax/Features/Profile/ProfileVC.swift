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
        case workout
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
        title = "Profile"
        
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
        
        let monthlyChartregistration = UICollectionView.CellRegistration<UICollectionViewCell, [MonthlyChartData]>{(cell, indexPath, item) in
            cell.contentConfiguration = UIHostingConfiguration{
                MonthlyChart(data: item)
            }
            
            var background = UIBackgroundConfiguration.listCell()
            background.cornerRadius = 12
            cell.backgroundConfiguration = background
        }
        
        
        dataSource = DataSource(collectionView: contentView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier{
                
            case .profileInfo(let userData):
                return collectionView.dequeueConfiguredReusableCell(using: profileInfoRegistration, for: indexPath, item: userData)
            case .chart(let chartDataArry):
                return collectionView.dequeueConfiguredReusableCell(using: monthlyChartregistration, for: indexPath, item: chartDataArry)
            default:
                fatalError("Unhandled case")
                
            }
        })
    }
    
    private func bindViewModel(){
        viewModel.output.userInfo
            .combineLatest(viewModel.output.chartData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (userData, chartData) in
                guard let self else {return}
                guard let userData else {return}
                self.updateSnapshot(with: userData, chartData: chartData)
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
    
    private func showLoadingSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.profile])
        
        
        let dummyUser = UserModel(id: "dummy", name: "", email: "", profileImage: nil)
        snapshot.appendItems([.profileInfo(dummyUser)])
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func updateSnapshot(with profileInfo: UserModel, chartData: [MonthlyChartData]){
        var snapshot = Snapshot()
        
        snapshot.appendSections([.profile, .charts])
        snapshot.appendItems([.profileInfo(profileInfo)])
        
        snapshot.appendItems([.chart(chartData)], toSection: .charts)
        
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

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
