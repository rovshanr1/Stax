//
//  ExerciseListVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.12.25.
//

import UIKit
import SnapKit
import Combine
import CoreData


class ExerciseListVC: UIViewController {
    //MARK: - Diffable DataSource Types
    enum Section: String{
        case main
    }
    
    // Typealiases
    typealias DataSource = UITableViewDiffableDataSource<Section, NSManagedObjectID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, NSManagedObjectID>
    
    //Internal Properties
    var didSendEventClosure: ((ExerciseListEvent) -> Void)?
    var viewModel: ExerciseListVM!
    
    //Private Properties
    private var cancellables: Set<AnyCancellable> = []
    private var dataSource: DataSource!
    private var allExercises: [Exercise] = []
    
    
    //ContentView
    let contentView = ExerciseListView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()
        bindVM()
        setupDelegate()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(contentView)
        
        setupNavbar()
        setupConstraints()
    }
    
    private func setupConstraints() {
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(0)
        }
    }
    
    private func setupDelegate(){
        contentView.tableView.delegate = self
        contentView.searchBar.delegate = self
    }
    
    //MARK: - Diffable DataSource Configuration
    private func configureDataSource(){
        dataSource = DataSource(tableView: contentView.tableView, cellProvider: { [weak self] (tableView, indexPath, id) -> UITableViewCell? in
            guard let self else {return nil}
            
            guard let exercise = self.allExercises.first(where: { $0.objectID == id }) else {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseListCell.reuseIdentifier, for: indexPath)
            
            var content = cell.defaultContentConfiguration()
            content.text = exercise.name
            content.secondaryText = exercise.category
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            
            return cell
        })
    }
    
    //MARK: - BindingVM
    private func bindVM(){
        viewModel.input.viewDidLoad.send()
        
        viewModel.output.exerciseList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exercise in
                guard let self else {return}
                
                print("exercises: \(exercise.count)")
                
                self.allExercises = exercise
                
                var snapshot = Snapshot()
                snapshot.appendSections([.main])
                
                let ids = exercise.map {$0.objectID}
                snapshot.appendItems(ids, toSection: .main)
                
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.navigationEvent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.didSendEventClosure?(event)
            }
            .store(in: &cancellables)
    }
}


//MARK: - TableViewDelegate
extension ExerciseListVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.input.didSelectRow.send(indexPath.row)
    }
}

//MARK: - SearchBarDelegate
extension ExerciseListVC: UISearchBarDelegate{
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.input.searchTrigger.send(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}



//MARK: - NavigationBarItems
extension ExerciseListVC {
    private func setupNavbar(){
        title = "Add Exercise"
        
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("cancel", for: .normal)
        cancelBtn.tintColor = .label
        cancelBtn.configuration?.imagePadding = 8
        cancelBtn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBtn)
        navigationItem.leftBarButtonItem?.hidesSharedBackground = true
    }
    
    
    @objc private func handleCancel(){
        didSendEventClosure?(.cancel)
    }
}
