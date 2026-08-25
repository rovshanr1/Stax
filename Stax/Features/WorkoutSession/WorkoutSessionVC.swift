//
//  WorkoutSessionVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.12.25.
//

import UIKit
import Combine

//MARK: - Diffable DataSource Types
nonisolated enum WorkoutSessionSection: CaseIterable, Sendable{
    case duration
    case exercises
}

nonisolated enum WorkoutSessionRowItems: Sendable{
    case duration
    case exercise(WorkoutExerciseDomainModel)
    case empty
}

class WorkoutSessionVC: UIViewController {
 
    //Typealiases
    typealias DataSource = UICollectionViewDiffableDataSource<WorkoutSessionSection, WorkoutSessionRowItems>
    typealias Snapshot = NSDiffableDataSourceSnapshot<WorkoutSessionSection, WorkoutSessionRowItems>
    
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
    private var scrollTask: Task<Void, Never>?
    
    private var isViewAppeared: Bool = false
    
    private let contentView = WorkoutSessionView()
    private var keyboardManager: KeyboardManager?
    
    private var dataSource: DataSource!
    
    private var sessionExercise: [WorkoutExerciseDomainModel] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        configureDataSource()
        bindVM()
        
        keyboardManager = KeyboardManager(scrollView: contentView.collectionView)
        contentView.collectionView.keyboardDismissMode = .onDrag
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isViewAppeared = true
        viewModel.input.viewDidAppear.send()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewAppeared = false
    }
    
    deinit{
        print("deinited WorkoutSessionVC")
        scrollTask?.cancel()
    }
    
    //MARK: - Layout
    private func createLayout() -> UICollectionViewCompositionalLayout{
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let section = self?.dataSource.snapshot().sectionIdentifiers[sectionIndex] else {
                return nil
            }
            
            return WorkoutSessionLayoutFactory.createSection(for: section)
        }
    }
    
    //MARK: - Diffable DataSource Configuration
    private func configureDataSource(){
        contentView.collectionView.collectionViewLayout = createLayout()
        contentView.collectionView.delegate = self
       
        
        let durationRegistration = UICollectionView.CellRegistration<WorkoutSessionDurationCell, Void>{ [weak self] cell, _, _ in
            guard let self else { return }
            
            let currentStats = self.viewModel.currentStats
            cell.updateStats(volume: currentStats.volume, sets: currentStats.sets)
        }
        
        let emptyRegistration = UICollectionView.CellRegistration<EmptyWorkoutCollectionViewCell, Void> { _, _, _ in }
            
        let exerciseRegistration = UICollectionView.CellRegistration<WorkoutSessionExerciseListCell, WorkoutExerciseDomainModel>{ [weak self] cell, _, exerciseItem in
            guard let self else { return}
            
            cell.configureExerciseCell(with: exerciseItem)
            cell.configureTextView(with: exerciseItem.notes)
            
            cell.onNoteChange = { [weak self] newNote in
                self?.viewModel.input.updateExerciseNote.send((exerciseItem.id, newNote))
            }
            
            cell.exerciseMenuOnTapped = { [weak self] in
                self?.showExerciseMenu(for: exerciseItem)
            }
            
            cell.addSetTapped = { [weak self] exercise in
                self?.viewModel.input.addSet.send(exercise)
            }
            
            cell.onToggleSetDone = { [weak self] setID, weight, reps, isDone in
                self?.viewModel.input.updateSet.send((setID, weight, reps, isDone))
            }
            
            cell.onInputFieldFocusChange = { [weak self] inputView in
                self?.scrollToVisible(inputView)
            }
            
            cell.deleteSetTapped = { [weak self] setID in
                self?.viewModel.input.deleteSet.send(setID)
            }
        }

        let separatorRegistration = UICollectionView.SupplementaryRegistration<SectionSeparatorView>(
            elementKind: SectionSeparatorView.elementKind
        ) { _, _, _ in }
        
        let footerRegistration = UICollectionView.SupplementaryRegistration<WorkoutSessionFooterView>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { [weak self] footerView, elementKind, indexPath in
            footerView.onTapAddExerciseButton = { [weak self] in
                guard let self else { return }
                
                self.didSendEventClosure?(.addExercise(onSelected: { [weak self] exercise in
                    self?.viewModel.input.addExercise.send(exercise)
                }))
            }
        }
        
        dataSource = DataSource(collectionView: contentView.collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .duration:
                return collectionView.dequeueConfiguredReusableCell(using: durationRegistration, for: indexPath, item: ())
            case .empty:
                return collectionView.dequeueConfiguredReusableCell(using: emptyRegistration, for: indexPath, item: ())
            case .exercise(let exerciseModel):
                return collectionView.dequeueConfiguredReusableCell(using: exerciseRegistration, for: indexPath, item: exerciseModel)
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            
            if kind == UICollectionView.elementKindSectionFooter{
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: footerRegistration,
                    for: indexPath
                )
            }else {
               return collectionView.dequeueConfiguredReusableSupplementary(using: separatorRegistration, for: indexPath)
            }
        }
    }
        
    private func scrollToVisible(_ inputView: UIView){
        scrollTask?.cancel()
        
        scrollTask = Task{ @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(0.1))
            
            guard !Task.isCancelled, let self else { return }
            
            let collectionView = self.contentView.collectionView
            let inputFrame = inputView.convert(inputView.bounds, to: collectionView)
            
            let visibleHeight = collectionView.bounds.height - collectionView.contentInset.bottom
            let targetY = inputFrame.origin.y - (visibleHeight / 2) + (inputFrame.height / 2)
            let maxScrollY = collectionView.contentSize.height - visibleHeight + collectionView.contentInset.bottom
            let clampedY = max(0, min(targetY, maxScrollY))
            
            collectionView.setContentOffset(CGPoint(x: 0, y: clampedY), animated: true)
        }
    }
    
    //MARK: - ViewModel Binding
    private func bindVM(){
        viewModel.output.timerSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timerString in
                self?.updateDurationCell(timerString: timerString)
                
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
                
                for cell in self.contentView.collectionView.visibleCells{
                    if let exerciseCell = cell as? WorkoutSessionExerciseListCell{
                        exerciseCell.shakeSetRow(with: setId)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateDurationCell(timerString: String? = nil, stats: (volume: Double, sets: Int)? = nil) {
        guard view.window != nil,
              let indexPath = dataSource.indexPath(for: .duration),
              let cell = contentView.collectionView.cellForItem(at: indexPath) as? WorkoutSessionDurationCell
        else { return }
        
        if let timerString {
            cell.configureTime(with: timerString)
        }
        if let stats {
            cell.updateStats(volume: stats.volume, sets: stats.sets)
        }
    }
       
    
    //MARK: - Update Snapshot
    private func updateSnapshot(with exercises: [WorkoutExerciseDomainModel]){
        var snapshot = Snapshot()
        snapshot.appendSections(WorkoutSessionSection.allCases)
        snapshot.appendItems([.duration], toSection: .duration)
        
        if exercises.isEmpty {
            snapshot.appendItems([.empty], toSection: .exercises)
        } else {
            let exerciseItems = exercises.map { WorkoutSessionRowItems.exercise($0) }
            
            snapshot.appendItems(exerciseItems, toSection: .exercises)
            
            if #available(iOS 15.0, *) {
                snapshot.reconfigureItems(exerciseItems)
            } else {
                snapshot.reloadItems(exerciseItems)
            }
            
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
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
extension WorkoutSessionVC: UICollectionViewDelegate{ }

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

