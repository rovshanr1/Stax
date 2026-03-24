//
//  WorkoutDetailVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 23.03.26.
//

import UIKit

final class WorkoutDetailVC: UIViewController{
    
    var didSendEventClosure: ((WorkoutDetailEvent) -> Void)?
    
    var vm: WorkoutDetailVM!
    
    var contentView = WorkoutDetailView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Workout Detail"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            didSendEventClosure?(.dismiss)
        }
    }
    
    deinit{
        print("WorkoutDetailDeinited")
    }
}
