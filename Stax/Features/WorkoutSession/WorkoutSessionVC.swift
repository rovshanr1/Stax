//
//  WorkoutSessionVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.12.25.
//

import UIKit
import SnapKit
import Combine

class WorkoutSessionVC: UIViewController {    
    //Internal Properties
    var didSendEventClosure: ((WorkoutSessionEvent) -> Void)?
    var viewModel: WorkoutSessionViewModel!
    
    //Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let contentView = WorkoutSessionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: - Setup UI Method
    private func setupUI(){
        view.backgroundColor = .systemBackground
        
        setupNavbar()
        constraints()
        bindVM()
        bindEvents()
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
    }
    
}

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
