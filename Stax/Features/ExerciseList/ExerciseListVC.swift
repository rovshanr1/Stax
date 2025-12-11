//
//  ExerciseListVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.12.25.
//

import UIKit

class ExerciseListVC: UIViewController {

    var didSendEventClosure: ((ExerciseListEvent) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    private func setupUI() {
        setupNavbar()
    }
}


//MARK: - NavigationBarItems
extension ExerciseListVC {
    private func setupNavbar(){
        title = "Add Exercise"
        
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("cancel", for: .normal)
        cancelBtn.tintColor = .label
        cancelBtn.configuration?.imagePadding = 8
        cancelBtn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBtn)
        navigationItem.leftBarButtonItem?.hidesSharedBackground = true
    }
    
    
    @objc private func handleCancel(){
        didSendEventClosure?(.cancel)
    }
}
