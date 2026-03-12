//
//  HomeVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit
import Combine
import SnapKit


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
        setupUI()
        configureDataSource()
        bindVM()
    }
    
    private func setupUI(){
        title = "Home"
        view.backgroundColor = .systemBackground
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(0)
        }
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
                    self?.didSendEventClosure?(.moreButtonTapped(id: presentationItem.id))
                }
                
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
extension HomeVC: UITableViewDelegate{}
