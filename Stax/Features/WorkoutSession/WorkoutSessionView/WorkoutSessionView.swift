//
//  WorkoutSessionView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.12.25.
//

import UIKit
import SnapKit

class WorkoutSessionView: UIView {
    var addExerciseButtonTapped: (() -> Void)?
    
    var tableView: UITableView = {
       let uiTableView = UITableView()
        uiTableView.register(WorkoutSessionTableViewCell.self, forCellReuseIdentifier: WorkoutSessionTableViewCell.reuseIdentifier)
        uiTableView.register(DividerCell.self, forCellReuseIdentifier: DividerCell.reuseIdentifier)
        uiTableView.register(EmptyWorkoutTableViewCell.self, forCellReuseIdentifier: EmptyWorkoutTableViewCell.reuseIdentifier)
        uiTableView.register(WorkoutSessionExerciseListCell.self, forCellReuseIdentifier: WorkoutSessionExerciseListCell.reuseIdentifier)
        uiTableView.register(AddExerciseButtonTableViewCell.self, forCellReuseIdentifier: AddExerciseButtonTableViewCell.reuseIdentifier)
        uiTableView.allowsSelection = false
        return uiTableView
    }()
    
    private var currentTimerString: String = "0h 0m 00s"

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(){
        addSubview(tableView)
        tableView.separatorStyle = .none
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func updateTimer(_ time: String){
        self.currentTimerString = time
        let indexPath = IndexPath(row: 0, section: 0)
        
        if let cell = tableView.cellForRow(at: indexPath) as? WorkoutSessionTableViewCell {
            cell.configureTime(with: currentTimerString)
        }
    }
}

