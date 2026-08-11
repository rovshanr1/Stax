//
//  WorkoutSummaryVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.01.26.
//

import UIKit
import Combine

class WorkoutSummaryVC: UIViewController {
    
    //Callbakc
    var onDeinit: (() -> Void)?
    
    //Content View Callback
    var headerTitleOnChanged: ((String) -> Void)?
    
    //Internal Properties
    var didSendEventClosure: ((WorkoutSummaryEvent) -> Void)?
    var viewModel: WorkoutSummaryViewModel
    
    init(viewModel: WorkoutSummaryViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var contentView = WorkoutSummaryView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        bindEvent()
        bindViewModel()
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    deinit{
        onDeinit?()
        print("deinited summary")
    }
    
    
    private func bindEvent() {
        contentView.titleOnChanged = { [weak self] title in
            self?.viewModel.input.updateTitle.send(title)
        }
        
        contentView.descriptionOnChange = { [weak self] description in
            self?.viewModel.input.updateDescription.send(description)
        }
        
        contentView.syncButtonOnTapped = { [weak self] in
            self?.showSyncSheet()
        }
        
        contentView.discardButtonOnTapped = { [weak self] in
            self?.confirmDiscard()
        }
    }
    
    private func bindViewModel() {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.input.viewDidLoad.send()
        }
        
        viewModel.output.workoutStats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] presentation in
                guard let self, let workout = viewModel.workout else { return }
                self.contentView.informationView.configureInformations(
                    duration: presentation.duration,
                    volume: presentation.volume,
                    sets: presentation.sets,
                    date: workout.date ?? Date()
                )
            }
            .store(in: &cancellables)
        
        viewModel.output.defaultTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.contentView.headerView.configureHeader(title)
            }
            .store(in: &cancellables)
        
        viewModel.output.isHealthKitSyncEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.contentView.configureSyncButton(isEnabled: isEnabled)
            }
            .store(in: &cancellables)
        
        viewModel.output.finished
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.didSendEventClosure?(.workoutSaved)
            }
            .store(in: &cancellables)
    }
    
    private func showSyncSheet() {
        let currentState = viewModel.output.isHealthKitSyncEnabled.value
        let sheetNav = SyncWithSheet(initialSyncState: currentState)
        sheetNav.modalPresentationStyle = .pageSheet
        
        if let sheet = sheetNav.sheetPresentationController {
            sheet.detents = [.custom(identifier: .init("small")) { _ in 150 }]
            sheet.prefersGrabberVisible = true
        }
        
        sheetNav.syncWithHealth = { [weak self] isEnabled in
            self?.viewModel.input.toggleHealthKitSync.send(isEnabled)
        }
        
        viewModel.output.isHealthKitSyncEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak sheetNav] isEnabled in
                sheetNav?.forceUpdateState(isEnabled)
            }
            .store(in: &cancellables)
        
        present(sheetNav, animated: true)
    }
    
    private func confirmDiscard() {
        AlertManager.showConfirmationAlert(
            on: self,
            title: nil,
            message: "Are you sure you want to discard this workout?",
            confirmTitle: "Discard Workout",
            cancelTitle: "Cancel"
        ) { [weak self] in
            guard let self else { return }
            self.viewModel.input.discardWorkout.send(())
            self.didSendEventClosure?(.workoutDiscarded)
        }
    }
}

//MARK: - NavigationBarItems
extension WorkoutSummaryVC{
    private func setupNavigationBar(){
        title = "Save Workout"
        
        let saveButton = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .label
        config.cornerStyle = .large
        config.baseBackgroundColor = .clear
        config.title = "Save"
        saveButton.configuration = config
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }
    
    //Actions
    @objc private func saveButtonTapped(){
        AlertManager.showConfirmationAlert(on: self, title: nil, message: "Save this workout?", confirmTitle: "Save", cancelTitle: "Cancel", action: { [weak self] in
            guard let self else {return}
            self.viewModel.input.saveWorkout.send()
        })
    }
}
