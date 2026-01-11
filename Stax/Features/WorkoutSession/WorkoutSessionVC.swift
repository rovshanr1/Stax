//
//  WorkoutSessionVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.12.25.
//

import UIKit
import SnapKit
import Combine
import CoreData


class WorkoutSessionVC: UIViewController {
    //MARK: - Diffable DataSource Types
    enum Section: String, CaseIterable{
        case duration
        case exercises
    }
    
    nonisolated enum RowItem: Hashable, Sendable{
        case duration
        case divider
        case exercise(NSManagedObjectID)
        case empty
    }
    
    //Typealiases
    typealias DataSource = UITableViewDiffableDataSource<Section, RowItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, RowItem>
    
    //Internal Properties
    var didSendEventClosure: ((WorkoutSessionEvent) -> Void)?
    var viewModel: WorkoutSessionViewModel!
    
    //Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let contentView = WorkoutSessionView()
    private var dataSource: DataSource!
    private var sessionExercise: [WorkoutExercise] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindVM()
        bindEvents()
        configureDataSource()
    }
    
    //MARK: - Setup UI
    private func setupUI(){
        view.backgroundColor = .systemBackground
        
        setupNavbar()
        constraints()
    }
    
    //MARK: - Constraints
    private func constraints(){
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(0)
        }
    }
    
    //MARK: - Event Binding
    private func bindEvents(){
        contentView.addExerciseButtonTapped = { [weak self] in
            self?.didSendEventClosure?(.addExercise)
        }
    }
    
    //MARK: - Diffable DataSource Configuration
    private func configureDataSource(){
        contentView.tableView.delegate = self
        
        dataSource = DataSource(tableView: contentView.tableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
            
            guard let self else {return nil}
            
            switch itemIdentifier {
            case .duration:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutSessionTableViewCell.reuseIdentifier, for: indexPath) as? WorkoutSessionTableViewCell else {
                    return UITableViewCell()
                }
                return cell
            case .divider:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DividerCell.reuseIdentifier, for: indexPath) as? DividerCell else{
                    return UITableViewCell()
                }
                return cell
            case .empty:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: EmptyWorkoutTableViewCell.reuseIdentifier, for: indexPath) as? EmptyWorkoutTableViewCell else{
                    return UITableViewCell()
                }
                return cell
            case .exercise(let id):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutSessionExerciseListCell.reuseIdentifier, for: indexPath) as? WorkoutSessionExerciseListCell else {
                    return UITableViewCell()
                }
                
                if let exerciseItem = self.sessionExercise.first(where: { $0.objectID == id}){
                    cell.configureExerciseCell(with: exerciseItem.exercise!)
                    
                    
                    cell.configureTextView(with: exerciseItem.note)
                    
                    cell.onNoteChange = { [weak self] newNote in
                        self?.viewModel.input.updateExerciseNote.send((id, newNote))
                    }
                    
                    cell.onNotesHeightChange = { [weak self]  in
                        self?.contentView.tableView.beginUpdates()
                        self?.contentView.tableView.endUpdates()
                    }
                    
                    cell.exerciseMenuOnTapped = { [weak self] in
                        self?.didSendEventClosure?(.exerciseMenuButtonTapped(exerciseItem))
                    }
                    
                }
                return cell
            }
        })
    }

    
    //MARK: - ViewModel Binding
    private func bindVM(){
        viewModel.output.timerSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timerString in
                self?.contentView.updateTimer(timerString)
                
            }
            .store(in: &cancellables)
        
        viewModel.output.dismissEvent
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                self?.didSendEventClosure?(.finishWorkout)
            }
            .store(in: &cancellables)
        
        viewModel.input.viewDidLoad.send()
        
        viewModel.output.exercises
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exercises in
                guard let self else {return}
                
                self.sessionExercise = exercises
                self.updateSnapshot(with: exercises)
            }
            .store(in: &cancellables)
    }
    
    private func updateSnapshot(with exercises: [WorkoutExercise]){
        var snapshot = dataSource.snapshot()
        
        let isInitialLoad = snapshot.sectionIdentifiers.isEmpty
        
        if isInitialLoad{
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems([.duration, .divider], toSection: .duration)
        }
        
        let oldItems = snapshot.itemIdentifiers(inSection: .exercises)
        snapshot.deleteItems(oldItems)
        
        if exercises.isEmpty{
            snapshot.appendItems([.empty], toSection: .exercises)
        }else{
            let items = exercises.map {RowItem.exercise($0.objectID)}
            snapshot.appendItems(items, toSection: .exercises)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}



//MARK: - TableViewDelegate
extension WorkoutSessionVC: UITableViewDelegate{ }

//MARK: - NavigationBarItems
extension WorkoutSessionVC{
    private func setupNavbar() {
        title = "Active Session"
        
        let finishBtn = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .label
        config.cornerStyle = .large
        config.baseBackgroundColor = .clear
        config.title = "Finish"
        finishBtn.configuration = config
        finishBtn.addTarget(self, action: #selector(finishSession), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: finishBtn)
        navigationItem.rightBarButtonItem?.hidesSharedBackground = true
        
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        cancelBtn.tintColor = .label
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelBtn.addTarget(self, action: #selector(cancelSession), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBtn)
    }
    
    //MARK: - Action
    @objc private func finishSession() {
        AlertManager.showConfirmationAlert(
            on: self,
            title: "Finish Workout",
            message: "Do you want to save and end this workout?",
            confirmTitle: "Save & Finish",
            cancelTitle: "Continue Workout"
        ){[weak self] in
            guard let self else{return}
            self.viewModel.input.didTapFinish.send(())
        }
    }
    
    @objc private func cancelSession(){
        AlertManager.showConfirmationAlert(on: self,
                                           title: "Cancel Workout!",
                                           message: "Are you sure you want to cancel this workout?",
                                           confirmTitle: "Yes",
                                           cancelTitle: "No")
        { [weak self] in
            guard let self else { return }
            didSendEventClosure?(.finishWorkout)
        }
        
        
    }
}

