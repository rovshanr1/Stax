//
//  WorkoutVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit
import SnapKit

class WorkoutVC: UIViewController {
    var didSendEventClosure: ((ExerciseEvent) -> Void)?
    
    private var contentView = WorkoutView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Workout"
        bindEvent()
        setupUI()
    }
    
    private func bindEvent(){
        contentView.didTapStartButton = { [weak self] in
            self?.didSendEventClosure?(.startEmptyWorkout)
        }
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
    
}
