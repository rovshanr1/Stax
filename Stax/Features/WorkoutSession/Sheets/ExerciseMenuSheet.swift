//
//  ExerciseMenuSheet.swift
//  Stax
//
//  Created by Rovshan Rasulov on 08.01.26.
//

import UIKit
import SnapKit

final class ExerciseMenuSheet: UIViewController {
    enum Action {
        case deleteExercise
        case replaceExercise
    }
    
    let contentView = SheetView()
    
    //ContentView
    private let deleteExercise = CustomSheetButton()
    private let replaceExercise = CustomSheetButton()
    
    //Stack View
    
    var onActionSelected: ((Action) -> Void)?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [replaceExercise, deleteExercise])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 0.5
        stackView.backgroundColor = .separator
        stackView.layer.cornerRadius = 16
        stackView.clipsToBounds = true
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSheetUI()
        bindAction()
    }
    
    private func setupSheetUI(){
        view.addSubview(stackView)
        view.backgroundColor = .systemBackground
        
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        replaceExercise.configButton(title: "Replace Exercise", iconName: "arrow.2.circlepath", textColor: .label)
        deleteExercise.configButton(title: "Remove Exercise", iconName: "xmark.circle", textColor: .systemRed)
        
       
    }
    
    private func bindAction(){
        replaceExercise.buttonTapped = {[weak self] in
            self?.onActionSelected?(.replaceExercise)
        }
        
        deleteExercise.buttonTapped = {[weak self] in
            self?.onActionSelected?(.deleteExercise)
        }
    }
}
