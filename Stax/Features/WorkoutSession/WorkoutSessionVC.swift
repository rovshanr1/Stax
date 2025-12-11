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
    var didSendEventClosure: ((WorkoutSessionEvent) -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let contentView = WorkoutSessionView()
    
    var viewModel: WorkoutSessionViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavbar()
        setupUI()
        bindVM()
        bindEvents()
    }
    
    private func setupUI(){
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(0)
        }
    }
    
    private func bindEvents(){
        contentView.addExerciseButtonTapped = { [weak self] in
            self?.didSendEventClosure?(.addExercise)
        }
    }
    
    
    private func bindVM(){
        viewModel.output.timerSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timerString in
                self?.contentView.updateTimer(timerString)
                
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
    
    @objc private func finishSession() {
        AlertManager.showErrorAlert(on: self, with: WorkoutServiceError.noAddExercise)
    }
    
    @objc private func cancelSession(){
        didSendEventClosure?(.finishWorkout)
    }
}
