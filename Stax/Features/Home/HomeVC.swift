//
//  HomeVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit
import Combine

class HomeVC: UIViewController {
    //MARK: - Diffable DataSource
    nonisolated enum Section: CaseIterable, Sendable {case main}
    nonisolated enum RowItem: Hashable, Sendable {case workout(HomeWorkoutPresentationItem)}
    
    typealias DataSource = UITableViewDiffableDataSource<Section, RowItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, RowItem>
    
    
    //Closures
    var didSendEventClosure: ((HomeEvent) -> Void)?
    
    //States
    private var currentWorkout: [HomeWorkoutPresentationItem] = []
    
    //ViewModel
    var vm: HomeVM!
    
    //private properties
    private let contentView = HomeUiView()
    private var dataSource: DataSource!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
    
        configureDataSource()
        bindVM()
    }
    
    override func loadView() {
        self.view = contentView
    }
    

    //MARK: - Datasource Configuration
    private func configureDataSource(){
        contentView.tableView.delegate = self
        
        dataSource = DataSource(tableView: contentView.tableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
            
            guard self != nil else {return nil}
            
            switch itemIdentifier {
            case .workout(let presentationItem):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier,for: indexPath) as? HomeTableViewCell else {return UITableViewCell()}
                cell.headerView.configureHomeHeaderView(name: presentationItem.title, time: presentationItem.time, volume: presentationItem.volume )
                cell.headerMoreButtonTapped = { [weak self] in
                    self?.didSendEventClosure?(.workoutMenuButtonTapped(id: presentationItem.id))
                }
                
                cell.configureExercise(exercise: presentationItem.exerciseSummar, moreText: presentationItem.moreText)
                return cell
            }
        })
        
    }
    
    //MARK: - Combine Binding
    private func bindVM(){
        vm.output.workouts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] workouts in
                self?.currentWorkout = workouts
                self?.updateSnapshot(with: workouts)
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
    
    //MARK: - Update Snapshot
    private func updateSnapshot(with items: [HomeWorkoutPresentationItem]){
        var snaphot = Snapshot()
        snaphot.appendSections([.main])
        
        let rowItems = items.map { RowItem.workout($0)}
        snaphot.appendItems(rowItems, toSection: .main)
        
        dataSource.apply(snaphot, animatingDifferences: true)
    }
}

//MARK: - TableViewDelegate
extension HomeVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch selectedItem {
        case .workout(let presentetionItem):
            didSendEventClosure?(.presentWorkoutDetails(id: presentetionItem.id))
        }
    }
}
