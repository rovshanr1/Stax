//
//  WorkoutDetailView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.03.26.
//

import UIKit
import SnapKit

class WorkoutDetailView: UIView {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(WorkoutDetailTableViewCell.self, forCellReuseIdentifier: WorkoutDetailTableViewCell.identifier)
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(tableView)
        backgroundColor = .systemBackground
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
