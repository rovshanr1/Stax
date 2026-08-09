//
//  WorkoutSessionVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.12.25.
//

import UIKit
import Combine

class WorkoutSessionVC: UIViewController {
    //MARK: - Diffable DataSource Types
    nonisolated enum Section: CaseIterable, Sendable{
        case duration
        case exercises
    }
    
    nonisolated enum RowItem: Hashable, Sendable{
        case duration
        case exercise(String)
        case empty
    }
    
    //Typealiases
    typealias DataSource = UITableViewDiffableDataSource<Section, RowItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, RowItem>
    
    //Internal Properties
    var didSendEventClosure: ((WorkoutSessionEvent) -> Void)?
    private let viewModel: WorkoutSessionViewModel
    
    init(viewModel: WorkoutSessionViewModel){
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let contentView = WorkoutSessionView()
    private var dataSource: DataSource!
    private var sessionExercise: [WorkoutExerciseDomainModel] = []
    private var isViewApeared: Bool = false
    private var keyboardManager: KeyboardManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        configureDataSource()
        bindVM()
        bindEvents()
        
       
        
        keyboardManager = KeyboardManager(scrollView: contentView.tableView)
        contentView.tableView.keyboardDismissMode = .onDrag
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isViewApeared = true
        viewModel.input.viewDidAppear.send()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewApeared = false
    }
    
    deinit{
        print("deinited WorkoutSessionVC")
    }
    
    //MARK: - Event Binding
    private func bindEvents() {
        contentView.addExerciseButtonTapped = { [weak self] in
            guard let self else { return }
            self.didSendEventClosure?(.addExercise(onSelected: { [weak self] exercise in
                self?.viewModel.input.addExercise.send(exercise)
            }))
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
                let currentStats = self.viewModel.currentStats
                cell.updateStats(volume: currentStats.volume, sets: currentStats.sets)
                
                
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
                
                if let exerciseItem = self.sessionExercise.first(where: { $0.id == id}){
                    cell.configureExerciseCell(with: exerciseItem)
                    
                    
                    cell.configureTextView(with: exerciseItem.notes)
                    
                    cell.onNoteChange = { [weak self] newNote in
                        self?.viewModel.input.updateExerciseNote.send((id, newNote))
                    }
                    
                    cell.onNotesHeightChange = { [weak self]  in
                        self?.contentView.tableView.beginUpdates()
                        self?.contentView.tableView.endUpdates()
                    }
                    
                    cell.exerciseMenuOnTapped = { [weak self] in
                        self?.showExerciseMenu(for: exerciseItem)
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
        
        viewModel.output.cancelWorkoutEvent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                self.didSendEventClosure?(.cancelWorkout)
            }
            .store(in: &cancellables)
        
        viewModel.output.finishWorkoutEvent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (workout, stats) in
                self?.didSendEventClosure?(.finishWorkout(workoutID: workout, stats: stats))
            }
            .store(in: &cancellables)
        
        viewModel.output.setValidationError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] setId in
                guard let self else { return }
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                
                for cell in self.contentView.tableView.visibleCells{
                    if let exerciseCell = cell as? WorkoutSessionExerciseListCell{
                        exerciseCell.shakeSetRow(with: setId)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateDurationCell(stats: (volume: Double, sets: Int)? = nil){
        guard self.view.window != nil else {return}
        
        guard let indexPath = dataSource.indexPath(for: .duration) else {return}
        guard let cell = contentView.tableView.cellForRow(at: indexPath) as? WorkoutSessionTableViewCell else {return}
        
        if let stats{
            cell.updateStats(volume: stats.volume, sets: stats.sets)
        }
    }
    
    //MARK: - Update Snapshot
    private func updateSnapshot(with exercises: [WorkoutExerciseDomainModel]){
        var snapshot = Snapshot()
        
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems([.duration], toSection: .duration)
        
        
        if exercises.isEmpty{
            snapshot.appendItems([.empty], toSection: .exercises)
        }else{
            let items = exercises.map {RowItem.exercise($0.id)}
            snapshot.appendItems(items, toSection: .exercises)
        }
        
        guard isViewApeared else {
            dataSource.apply(snapshot, animatingDifferences: false)
            return
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
        
        for cell in contentView.tableView.visibleCells {
            if let exerciseCell = cell as? WorkoutSessionExerciseListCell,
               let indexPath = contentView.tableView.indexPath(for: exerciseCell),
               case .exercise(let id) = dataSource.itemIdentifier(for: indexPath),
               let updateExercise = exercises.first(where: { $0.id == id }) {
                exerciseCell.configureExerciseCell(with: updateExercise)
            }
        }
        
        UIView.performWithoutAnimation  {
            self.contentView.tableView.beginUpdates()
            self.contentView.tableView.endUpdates()
        }
       
    }
    
    //MARK: - Exercise Menu Navigation
    private func showExerciseMenu(for exercise: WorkoutExerciseDomainModel) {
        let sheetNav = ExerciseMenuSheet()
        sheetNav.modalPresentationStyle = .pageSheet
        
        if let sheet = sheetNav.sheetPresentationController {
            sheet.detents = [.custom(identifier: .init("small")) { _ in 120 }]
            sheet.prefersGrabberVisible = true
        }
        
        sheetNav.onActionSelected = { [weak self, weak sheetNav] action in
            guard let self, let sheetNav else { return }
            
            sheetNav.dismiss(animated: true) {
                switch action {
                case .replaceExercise:
                    self.didSendEventClosure?(.replaceExercise(exercise, onSelected: { [weak self] newExercise in
                        self?.viewModel.input.replaceExercise.send((exercise, newExercise))
                    }))
                case .deleteExercise:
                    self.viewModel.input.deleteExercise.send(exercise)
                }
            }
        }
        
        present(sheetNav, animated: true)
    }
    
    
    //MARK: - Public Methods
    func addExercise(_ exercise: ExerciseDomainModel){
        viewModel.input.addExercise.send(exercise)
    }
    
    func replaceExercise(_ old: WorkoutExerciseDomainModel, with new: ExerciseDomainModel){
        viewModel.input.replaceExercise.send((old, new))
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
        }
    }
}

