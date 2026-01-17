//
//  WorkoutSessionView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.12.25.
//

import UIKit
import SnapKit

final class WorkoutSessionView: UIView {
    
    var addExerciseButtonTapped: (() -> Void)?
    
    private lazy var footerView: WorkoutSessionFooterView = {
        let view = WorkoutSessionFooterView()
        
        view.onTapAddExerciseButton = { [weak self] in
            self?.addExerciseButtonTapped?()
        }
        
        return view
    }()
    
    var tableView: UITableView = {
       let uiTableView = UITableView()
        
        uiTableView.register(WorkoutSessionTableViewCell.self, forCellReuseIdentifier: WorkoutSessionTableViewCell.reuseIdentifier)
        uiTableView.register(DividerCell.self, forCellReuseIdentifier: DividerCell.reuseIdentifier)
        uiTableView.register(EmptyWorkoutTableViewCell.self, forCellReuseIdentifier: EmptyWorkoutTableViewCell.reuseIdentifier)
        uiTableView.register(WorkoutSessionExerciseListCell.self, forCellReuseIdentifier: WorkoutSessionExerciseListCell.reuseIdentifier)
        
        uiTableView.allowsSelection = false
        uiTableView.rowHeight = UITableView.automaticDimension
        uiTableView.estimatedRowHeight = 100
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutFooterView()
    }

    private func setupUI(){
        addSubview(tableView)
        tableView.separatorStyle = .none
        
        tableView.tableFooterView = footerView
        
        layoutFooterView()
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    private func layoutFooterView(){
        guard let footerView = tableView.tableFooterView else {return}
        
        let width = tableView.bounds.width
        let size = footerView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        )
        
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height
            tableView.tableFooterView = footerView
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
