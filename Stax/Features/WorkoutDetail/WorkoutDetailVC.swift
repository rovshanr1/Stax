//
//  WorkoutDetailVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 23.03.26.
//

import UIKit
import SwiftUI
import Combine

final class WorkoutDetailVC: UIViewController{
    //MARK: - Diffable Data Source
    nonisolated enum Section: Hashable, Sendable {
        case summary
        case muscleSplit
        case exercises(id: UUID)
    }
    nonisolated enum RowItem: Hashable, Sendable {
        case summaryInfo(DetailSummaryItems)
        case muscleSplitChart(MuscleSplitItem)
        case exerciseTitle(DetailExerciseHeaderItem)
        case setDetail(DetailSetRowItem)
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, RowItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, RowItem>
    
    //Closures
    var didSendEventClosure: ((WorkoutDetailEvent) -> Void)?
    
    var vm: WorkoutDetailVM!
    
    //private properties
    private var contentView = WorkoutDetailView()
    private var dataSource: DataSource!
    
    private var cancellables: Set<AnyCancellable> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Workout Detail"
        navigationItem.largeTitleDisplayMode = .never
        
        configureDataSource()
        bindViewModel()
        
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            didSendEventClosure?(.dismiss)
        }
    }
    
    deinit{
        print("WorkoutDetailDeinited")
    }
    
   
    
    //MARK: - DataSource Configuration
    private func configureDataSource(){
        contentView.collectionView.delegate = self
        
        
        let summaryRegistration = UICollectionView.CellRegistration<WorkoutSummaryCell, DetailSummaryItems> { (cell, indexPath, item) in
            cell.configureWorkoutSummarCell(with: item)
            
        }
        
        let muscleSplitRegistration = UICollectionView.CellRegistration<UICollectionViewCell, MuscleSplitItem> { (cell, indexPath, item) in
            cell.contentConfiguration = UIHostingConfiguration{
                MuscleSplitChartView(chartData: item.muscleData)
            }
            
            cell.backgroundColor = .systemBackground
        }
        
        let exerciseTitle = UICollectionView.CellRegistration<WorkoutExerciseHeaderCell, DetailExerciseHeaderItem> { (cell, indexPath, item) in
            
            cell.backgroundColor = .systemRed
        }
        
        let setDetail = UICollectionView.CellRegistration<WorkoutSetCell, DetailSetRowItem> { (cell, indexPath, item) in
            
            cell.backgroundColor = .systemRed
        }
        
        
        dataSource = DataSource(collectionView: contentView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier{
            case .summaryInfo(let summaryData):
                return collectionView.dequeueConfiguredReusableCell(using: summaryRegistration, for: indexPath, item: summaryData)
            case .muscleSplitChart(let splitData):
                return collectionView.dequeueConfiguredReusableCell(using: muscleSplitRegistration, for: indexPath, item: splitData)
            case .exerciseTitle(let title):
                return collectionView.dequeueConfiguredReusableCell(using: exerciseTitle, for: indexPath, item: title)
            case .setDetail(let detail):
                return collectionView.dequeueConfiguredReusableCell(using: setDetail, for: indexPath, item: detail)
            }
        })
        
    }
    
    private func bindViewModel(){
        
        vm.output.summaryData
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] summaryItem in
                self?.updateSnapshot(with: [summaryItem])
            }
            .store(in: &cancellables)
        
        
        DispatchQueue.main.async {[weak self] in
            self?.vm.input.viewDidLoad.send()
        }
    }
    
    //MARK: - Update Snapshot
        private func updateSnapshot(with summaryInfo: [DetailSummaryItems]){
            var snapshot = Snapshot()
            
            snapshot.appendSections([.summary, .muscleSplit])
            
            
            let mappedSummaryItems = summaryInfo.map { RowItem.summaryInfo($0) }
            snapshot.appendItems(mappedSummaryItems, toSection: .summary)
            
  
            let dummyMuscleData = [
                MuscleData(muscleName: "Chest", percentage: 45.0),
                MuscleData(muscleName: "Back", percentage: 30.0),
                MuscleData(muscleName: "Triceps", percentage: 25.0)
            ]
            
            let dummySplitItem = MuscleSplitItem(muscleData: dummyMuscleData)
            snapshot.appendItems([.muscleSplitChart(dummySplitItem)], toSection: .muscleSplit)
            
            dataSource.apply(snapshot, animatingDifferences: true)
        }
}

extension WorkoutDetailVC: UICollectionViewDelegate{
    
}


