//
//  WorkoutVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit

class WorkoutVC: UIViewController {
    var didSendEventClosure: ((WorkoutEvent) -> Void)?
    
    private var contentView = WorkoutView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLeftAlignedNavigationTitle(with: "Workout")
        
        bindEvent()
        setupTableView()
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    private func bindEvent(){
        contentView.didTapStartButton = { [weak self] in
            self?.didSendEventClosure?(.startEmptyWorkout)
        }
    }
    

    
    private func setupTableView(){
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
    }
}


extension WorkoutVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WorkoutTableViewCell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.reuseIdentifier, for: indexPath) as! WorkoutTableViewCell
        return cell
    }
}
