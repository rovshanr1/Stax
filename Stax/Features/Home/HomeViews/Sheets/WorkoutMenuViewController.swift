//
//  WorkoutMenuViewController.swift
//  Stax
//
//  Created by Rovshan Rasulov on 12.03.26.
//

import UIKit
import SnapKit

class WorkoutMenuViewController: UIViewController {
    enum Action{
        case edit
        case share
        case delete
    }
    
    //ContentView
    private let editActionView = CustomSheetButton()
    private let shareActionView = CustomSheetButton()
    private let deleteActionView = CustomSheetButton()

    var onActionSelected: ((Action) -> Void)?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [editActionView, shareActionView, deleteActionView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 0.5
        stackView.backgroundColor = .separator
        stackView.layer.cornerRadius = 16
        stackView.clipsToBounds = true
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        handleEvent()
    }
    
    deinit{
        print("sheet deinited")
    }
    
    
    private func setupUI(){
        view.addSubview(stackView)
        view.backgroundColor = .systemBackground
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        editActionView.configButton(title: "Edit Workout", iconName: "pencil", textColor: .label)
        shareActionView.configButton(title: "Share Workout", iconName: "square.and.arrow.up", textColor: .label)
        deleteActionView.configButton(title: "Delete Workout", iconName: "trash", textColor: .systemRed)
    }
    
    private func handleEvent(){
        editActionView.buttonTapped = {[weak self] in
            guard let self else {return}
            self.onActionSelected?(.edit)
        }
        
        shareActionView.buttonTapped = {[weak self] in
            guard let self else {return}
            self.onActionSelected?(.share)
        }
        
        deleteActionView.buttonTapped = {[weak self] in
            guard let self else {return}
            self.onActionSelected?(.delete)
        }
    }
}
