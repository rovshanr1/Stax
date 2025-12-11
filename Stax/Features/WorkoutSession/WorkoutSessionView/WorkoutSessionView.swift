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
    
    
    private var tableView: UITableView = {
       let uiTableView = UITableView()
        uiTableView.register(WorkoutSessionTableViewCell.self, forCellReuseIdentifier: WorkoutSessionTableViewCell.reuseIdentifier)
        uiTableView.register(WorkoutSessionButtonsTableViewCell.self, forCellReuseIdentifier: WorkoutSessionButtonsTableViewCell.reuseIdentifier)
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
        
        tableView.delegate = self
        tableView.dataSource = self
        
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



extension WorkoutSessionView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutSessionTableViewCell.reuseIdentifier, for: indexPath) as? WorkoutSessionTableViewCell else {
                fatalError("Unable to dequeue WorkoutSessionTableViewCell")
            }
            
            cell.configureTime(with: currentTimerString)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutSessionButtonsTableViewCell.reuseIdentifier, for: indexPath) as? WorkoutSessionButtonsTableViewCell else {
                fatalError("Unable to dequeue WorkoutSessionTableViewCell")
                
            }
            
            cell.onTapAddExerciseButton = {[weak self] in
                self?.addExerciseButtonTapped?()
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}
