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
        bindEvent()
        bindViewModel()
    }
    
    deinit{
        onDeinit?()
    }
    
    private func setupUI(){
        view.addSubview(contentView)
        
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(0)
        }
        
    }
    
    private func bindEvent(){
        //Header View Callback
        contentView.titleOnChanged = {[weak self] title in
            guard let self else {return}
            self.viewModel?.input.updateTitle.send(title)
        }
        
        
        //Description View Callback
        contentView.descriptionOnChange = { [weak self] description in
            guard let self else { return }
            self.viewModel.input.updateDescription.send(description)
        }
        
        contentView.syncButtonOnTapped = { [weak self] in
            guard let self else {return}
            self.didSendEventClosure?(.syncButtpPressed)
        }
    }
    
    private func bindViewModel(){
        
        print("This method working")
        
        viewModel?.output.workoutStats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                print("received stats: \(stats)")
                
                guard let self else { return }
                
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute, .second]
                formatter.unitsStyle = .abbreviated
                let durationString = formatter.string(from: stats.duration) ?? "0s"
                
                print("Configuring View with: \(durationString)")
                
                self.contentView.informationView.configureInformations(duration: durationString, volume: stats.volume, sets: stats.totalSets, date: self.viewModel.workout.date ?? Date())
            }
            .store(in: &cancellables)
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
