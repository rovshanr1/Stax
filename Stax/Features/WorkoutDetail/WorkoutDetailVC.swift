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
        case listTitle(String)
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
        
        let titleRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String>{ (cell, indexPath, text ) in
            var content = cell.defaultContentConfiguration()
            content.text = text
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            content.textProperties.color = .secondaryLabel
            
            content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            cell.contentConfiguration = content
            cell.backgroundConfiguration = .clear()
        }
        
        let exerciseTitle = UICollectionView.CellRegistration<WorkoutExerciseHeaderCell, DetailExerciseHeaderItem> { (cell, indexPath, item) in
            cell.configureWorkoutExerciseHeader(title: item.exerciseName, image: nil)
            cell.backgroundColor = .systemBackground
        }
        
        let setDetail = UICollectionView.CellRegistration<WorkoutSetCell, DetailSetRowItem> { (cell, indexPath, item) in
            cell.configureWorkoutDetailSetCell(with: item)
            cell.backgroundColor = .systemBackground
        }
        
        
        dataSource = DataSource(collectionView: contentView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier{
            case .summaryInfo(let summaryData):
                return collectionView.dequeueConfiguredReusableCell(using: summaryRegistration, for: indexPath, item: summaryData)
            case .muscleSplitChart(let splitData):
                return collectionView.dequeueConfiguredReusableCell(using: muscleSplitRegistration, for: indexPath, item: splitData)
            case .listTitle(let text):
                return collectionView.dequeueConfiguredReusableCell(using: titleRegistration, for: indexPath, item: text)
            case .exerciseTitle(let title):
                return collectionView.dequeueConfiguredReusableCell(using: exerciseTitle, for: indexPath, item: title)
            case .setDetail(let detail):
                return collectionView.dequeueConfiguredReusableCell(using: setDetail, for: indexPath, item: detail)
            }
        })
        
    }
    
    private func bindViewModel(){
        
        Publishers.CombineLatest3(vm.output.summaryData, vm.output.muscleSplitData, vm.output.exerciseData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] summaryData, muscleSplit, exerciseData in
                guard let self = self,
                      let realSummary = summaryData,
                      let realSplit = muscleSplit,
                      let realExerciseData = exerciseData else { return }
                
                self.updateSnapshot(with: realSummary, muscleSplit: realSplit, exercises: realExerciseData)
            }
            .store(in: &cancellables)
            
        
        DispatchQueue.main.async {[weak self] in
            self?.vm.input.viewDidLoad.send()
        }
    }
    
    //MARK: - Update Snapshot
    private func updateSnapshot(with summaryInfo: DetailSummaryItems,  muscleSplit: MuscleSplitItem, exercises: [ExerciseSectionData]){
            var snapshot = Snapshot()
            
            snapshot.appendSections([.summary, .muscleSplit])
            snapshot.appendItems([.summaryInfo(summaryInfo)], toSection: .summary)
        snapshot.appendItems([.muscleSplitChart(muscleSplit), .listTitle("Workout")], toSection: .muscleSplit)
            
        for exerciseData in exercises {
            let dynamicSection = Section.exercises(id: exerciseData.sectionID)
            snapshot.appendSections([dynamicSection])
            snapshot.appendItems([.exerciseTitle(exerciseData.headerItem)], toSection: dynamicSection)
            
            let setRowItems = exerciseData.items.map { RowItem.setDetail($0) }
            snapshot.appendItems(setRowItems, toSection: dynamicSection)
        }
            
            dataSource.apply(snapshot, animatingDifferences: true)
        }
}

extension WorkoutDetailVC: UICollectionViewDelegate{
    
}


