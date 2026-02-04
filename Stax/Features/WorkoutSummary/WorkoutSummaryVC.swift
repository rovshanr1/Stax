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
    
    //Callbakc
    var onDeinit: (() -> Void)?
    
    //Content View Callback
    var headerTitleOnChanged: ((String) -> Void)?
    
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
        callbacked()
        
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
    
    private func callbacked(){
        //Header View Callback
        contentView.titleOnChanged = {[weak self] title in
            guard let self else {return}
            
            viewModel?.input.updateTitle.send(title)
        }
    }
    
}

//MARK: - NavigationBarItems
extension WorkoutSummaryVC{
    private func setupNavigationBar(){
        title = "Save Workout"
        
        let saveButton = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .label
        config.cornerStyle = .large
        config.baseBackgroundColor = .clear
        config.title = "Save"
        saveButton.configuration = config
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }
    
    //Actions
    @objc private func saveButtonTapped(){
        didSendEventClosure?(.saveWorkout)
    }
}

//MARK: - Table View Delegate
extension WorkoutSummaryVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutSummaryMainCell.reuseIdentifier) as? WorkoutSummaryMainCell else { return UITableViewCell()}
        
        return cell
        
    }
}
