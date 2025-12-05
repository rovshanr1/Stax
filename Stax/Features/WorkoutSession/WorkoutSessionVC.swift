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
    private var cancellables = Set<AnyCancellable>()
    
    private let contentView = WorkoutSessionView()
    
    private let viewModel = WorkoutSessionViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavbar()
        setupUI()
        bindVM()
    }
    
    private func setupUI(){
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 0,
                                                              left: 0,
                                                              bottom: 0,
                                                              right: 0))
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

//MARK: - NavigationItems
extension WorkoutSessionVC{
    private func setupNavbar() {
        title = "Active Session"
        
        let finishBtn = UIButton(type: .system)
        finishBtn.setTitle("Finish", for: .normal)
        finishBtn.tintColor = .label
        finishBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        finishBtn.addTarget(self, action: #selector(finishSession), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: finishBtn)
        
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        cancelBtn.tintColor = .label
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelBtn.addTarget(self, action: #selector(cancelSession), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBtn)
    }
    
    @objc private func finishSession() {
        
    }
    
    @objc private func cancelSession(){
        dismiss(animated: true)
    }
}
