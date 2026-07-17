//
//  HomeVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit
import Combine

class HomeVC: UIViewController {
    //MARK: - Diffable Data Source
    nonisolated enum Section: CaseIterable, Sendable {case main}
    nonisolated enum RowItem: Hashable, Sendable {
        case workout(HomeWorkoutPresentationItem)
        case emty
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, RowItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, RowItem>
    
    
    //Closures
    var didSendEventClosure: ((HomeEvent) -> Void)?
    
    //States
    private var currentWorkout: [HomeWorkoutPresentationItem] = []
    
    //ViewModel
    var vm: HomeVM!
    
    //private properties
    private let contentView = HomeUIView()
    private var dataSource: DataSource!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftAlignedNavigationTitle(with: "Home")
        
        configureDataSource()
        
        contentView.updateCollectionViewLayout(createLayout())
        bindVM()
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    
    // MARK: - Dynamic Compositional Layout Creation
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            
            let snapshot = self.dataSource?.snapshot()
            let isListEmpty = snapshot?.itemIdentifiers.contains(.emty) ?? true
            
            
            if isListEmpty {
                return HomeLayoutFactory.createEmptyStateSection()
            } else {
                return HomeLayoutFactory.createWorkoutListSection()
            }
        }
    }
    
    //MARK: - Datasource Configuration
    private func configureDataSource(){
        contentView.collectionView.delegate = self
        
        dataSource = DataSource(collectionView: contentView.collectionView, cellProvider: {collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .workout(let presentationItem):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.headerView.configureHomeHeaderView(name: presentationItem.title, time: presentationItem.time, volume: presentationItem.volume )
                cell.headerMoreButtonTapped = { [weak self] in
                    self?.workoutMenuPresent(for: presentationItem.id)
                }
                
                cell.configureExercise(exercise: presentationItem.exerciseSummar, moreText: presentationItem.moreText)
                return cell
            case .emty:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeEmptyStateCell.identifier, for: indexPath) as? HomeEmptyStateCell else {
                    return UICollectionViewCell()
                }
                
                cell.startWorkoutButtonTapped = {[weak self] in
                    self?.didSendEventClosure?(.startEmptyWorkout)
                }
                
                return cell
            }
        })
        
    }
    
    //MARK: - Combine Binding
    private func bindVM(){
        vm.output.workouts
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] workouts in
                guard let self else { return }
                self.currentWorkout = workouts
                self.updateSnapshot(with: workouts)
            }
            .store(in: &cancellables)
        
        DispatchQueue.main.async {[weak self] in
            self?.vm.input.viewDidLoad.send()
        }
        
        
        vm.output.showShareSheet
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self else { return }
                self.didSendEventClosure?(.presentShareSheet(text: text))
            }
            .store(in: &cancellables)
        
    }
    
    //MARK: - Workout Menu Presentation
    private func workoutMenuPresent(for id: String){
        let sheetNav = WorkoutMenuViewController()
        sheetNav.modalPresentationStyle = .pageSheet
        
        if let sheet = sheetNav.sheetPresentationController{
            sheet.detents = [.custom(resolver: { _ in 190})]
            sheet.prefersGrabberVisible = true
        }
        
        sheetNav.onActionSelected = { [weak self, weak sheetNav] action in
            guard let self, let sheetNav else { return }
            
            sheetNav.dismiss(animated: true) {
                switch action{
                case .edit:
                    self.didSendEventClosure?(.editWorkout(id: id))
                case .share:
                    self.vm.input.shareWorkout.send(id)
                case .delete:
                    self.vm.input.deleteWorkout.send(id)
                }
            }
        }
        
        self.present(sheetNav, animated: true)
        
    }
    
    //MARK: - Update Snapshot
    private func updateSnapshot(with items: [HomeWorkoutPresentationItem]){
        var snaphot = Snapshot()
        snaphot.appendSections([.main])
        
        if items.isEmpty{
            snaphot.appendItems([.emty], toSection: .main)
        }else{
            let rowItems = items.map { RowItem.workout($0)}
            snaphot.appendItems(rowItems, toSection: .main)
        }
        
        let isVisible = self.view.window != nil
        
        dataSource.apply(snaphot, animatingDifferences: isVisible) { [weak self] in
            self?.contentView.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}

//MARK: - CollectionViewDelegate
extension HomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch selectedItem {
        case .workout(let presentationItem):
            didSendEventClosure?(.presentWorkoutDetails(id: presentationItem.id))
        case .emty:
            break
        }
    }
}
