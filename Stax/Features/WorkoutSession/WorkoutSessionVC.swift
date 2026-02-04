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
        configureDataSource()
        bindVM()
        bindEvents()
        setupKeyboardObserver() 
        
        contentView.tableView.keyboardDismissMode = .onDrag
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel?.input.viewDidAppear.send()
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
                    cell.configureExerciseCell(with: exerciseItem)
                    
                    
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
                    
                    cell.addSetTapped = { [weak self] exercise in
                        self?.viewModel.input.addSet.send(exercise)
                    }
                    
                    cell.onToggleSetDone = { [weak self] setID, weight, reps, isDone in
                        guard let self else {return}
                        self.viewModel.input.updateSet.send((setID, weight, reps, isDone))
                    }
                    
                    cell.onInputFieldFocusChange = {[weak self] inputView in
                        guard let self else {return}
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            let tableView = self.contentView.tableView
                            
                            let inputFrame = inputView.convert(inputView.bounds, to: tableView)
                            
                            let visibleHeight = tableView.bounds.height - tableView.contentInset.bottom
                            let targetY = inputFrame.origin.y - (visibleHeight / 2) + (inputFrame.height / 2)
                            
                            let maxScrollY = tableView.contentSize.height - visibleHeight + tableView.contentInset.bottom
                            
                            let clampedY = max(0, min(targetY, maxScrollY))
                            
                            tableView.setContentOffset(CGPoint(x: 0, y: clampedY), animated: true)
                        }
                    }
                    
                    cell.deleteSetTapped = { [weak self] setID in
                        self?.viewModel.input.deleteSet.send(setID)
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
        
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.input.viewDidLoad.send()
        }
        
        viewModel.output.exercises
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exercises in
                guard let self else {return}
                
                self.sessionExercise = exercises
                self.updateSnapshot(with: exercises)
            }
            .store(in: &cancellables)
        
        viewModel.output.sessionStats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                guard let self else {return}
                self.updateDurationCell(stats: stats)
            }
            .store(in: &cancellables)
    }
    
    private func updateDurationCell(stats: (volume: Double, sets: Int)? = nil){
        guard let indexPath = dataSource.indexPath(for: .duration) else {return}
        guard let cell = contentView.tableView.cellForRow(at: indexPath) as? WorkoutSessionTableViewCell else {return}
        
        if let stats{
            cell.updateStats(volume: stats.volume, sets: stats.sets)
        }
    }
    
    //MARK: - Update Snapshot
    private func updateSnapshot(with exercises: [WorkoutExercise]){
        var snapshot = Snapshot()
        
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems([.duration, .divider], toSection: .duration)
        
        
        if exercises.isEmpty{
            snapshot.appendItems([.empty], toSection: .exercises)
        }else{
            let items = exercises.map {RowItem.exercise($0.objectID)}
            snapshot.appendItems(items, toSection: .exercises)
            
            let existingItem = dataSource.snapshot().itemIdentifiers
            let itemsToReconfigure = items.filter { existingItem.contains($0) }
            
            if !itemsToReconfigure.isEmpty {
                snapshot.reconfigureItems(itemsToReconfigure)
            }
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
        
        
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        cancelBtn.tintColor = .label
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelBtn.addTarget(self, action: #selector(cancelSession), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBtn)
    }
    
    //MARK: - Action
    @objc private func finishSession() {
        
        viewModel.input.didTapFinish.send()
        didSendEventClosure?(.finishWorkout)
    }
    
    @objc private func cancelSession(){
        AlertManager.showConfirmationAlert(on: self,
                                           title: "Cancel Workout!",
                                           message: "Are you sure you want to cancel this workout?",
                                           confirmTitle: "Yes",
                                           cancelTitle: "No")
        { [weak self] in
            guard let self else { return }
            self.viewModel.input.didTapCancel.send()
            didSendEventClosure?(.cancelWorkout)
        }
        
        
    }
}

//MARK: - Keyboard Handling
extension WorkoutSessionVC {
    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let extraBuffer: CGFloat = 50
        let bottomPadding = keyboardFrame.height + extraBuffer
        
        var contentInset = contentView.tableView.contentInset
        contentInset.bottom = bottomPadding
        
        var scrollIndicatorInsets = contentView.tableView.verticalScrollIndicatorInsets
        scrollIndicatorInsets.bottom = bottomPadding
        
        UIView.animate(withDuration: 0.3) {
            self.contentView.tableView.contentInset = contentInset
            self.contentView.tableView.verticalScrollIndicatorInsets = scrollIndicatorInsets
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        let contentInset = UIEdgeInsets.zero
        contentView.tableView.contentInset = contentInset
        contentView.tableView.verticalScrollIndicatorInsets = contentInset
    }
    
}
