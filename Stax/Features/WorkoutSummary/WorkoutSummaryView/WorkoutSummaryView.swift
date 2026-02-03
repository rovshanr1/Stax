//
//  WorkoutSummaryView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.01.26.
//

import UIKit
import SnapKit

final class WorkoutSummaryView: UIView {
    
    var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(WorkoutSummaryMainCell.self, forCellReuseIdentifier: WorkoutSummaryMainCell.reuseIdentifier)
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        return tableView
    }()
    
    let headerView = WorkoutSummaryHeaderView(frame: .zero)
    let footerView = WorkoutSummaryFooterView(frame: .zero)

    override func layoutSubviews() {
        super.layoutSubviews()
        
        headerView.frame.size.height = frame.height
        footerView.frame.size.height = frame.height
        
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
}
