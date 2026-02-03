//
//  WorkoutSummaryVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.01.26.
//

import UIKit
import Combine
import SnapKit

class WorkoutSummaryVC: UIViewController {
    
    //CallBakc
    var onDeinit: (() -> Void)?
    

    //Internal Properties
    var didSendEventClosure: ((WorkoutSummaryEvent) -> Void)?
    var viewModel: WorkoutSummaryViewModel!
    
    //Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var contentView = WorkoutSummaryView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        
    }
    deinit{
        onDeinit?()
    }
    
    private func setupUI(){
        view.addSubview(contentView)
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(0)
        }
    }

}

//MARK: - NavigationBarItems
extension WorkoutSummaryVC{
    private func setupNavigationBar(){
        title = "Save Workout"
    }
}

extension WorkoutSummaryVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutSummaryMainCell.reuseIdentifier) as? WorkoutSummaryMainCell else { return UITableViewCell()}
        
        return cell
    
    }
}
