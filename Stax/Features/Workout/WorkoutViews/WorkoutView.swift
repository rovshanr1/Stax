//
//  WorkoutView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 02.12.25.
//

import UIKit
import SnapKit

class WorkoutView: UIView {
    var didTapStartButton: (() -> Void)?
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(WorkoutTableViewCell.self, forCellReuseIdentifier: WorkoutTableViewCell.reuseIdentifier)
        return tableView
    }()

   override init(frame: CGRect) {
       super.init(frame: frame)
       setuptableHeaderView()
       setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setuptableHeaderView(){
        let header = TableViewHeader(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60))
        
        header.onTapEmptyWorkout = { [weak self] in
            self?.didTapStartButton?()
        }
        
        tableView.tableHeaderView = header
    }
    
    private func setupTableView(){
        addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

//MARK: - TableViewDelegate and DataSource
extension WorkoutView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WorkoutTableViewCell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.reuseIdentifier, for: indexPath) as! WorkoutTableViewCell
        return cell
    }
}
