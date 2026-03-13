//
//  MoreSheetViewController.swift
//  Stax
//
//  Created by Rovshan Rasulov on 12.03.26.
//

import UIKit
import SnapKit

class MoreSheetViewController: UIViewController {
    //Closures
    var sendEventClosure: ((HomeEvent) -> Void)?
    
    //ContentView
    private let editActionView = MoreSheetView()
    private let shareActionView = MoreSheetView()
    private let deleteActionView = MoreSheetView()

    
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
            print("Somethink")
        }
    }
}
