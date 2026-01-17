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
    
    var onActionSelected: ((Action) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSheetUI()
        setupConstraints()
        bindAction()
    }
    
    private func setupSheetUI(){
        view.addSubview(contentView)
      
    }
    
    private func setupConstraints(){
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(0)
        }
    }
    
    private func bindAction(){
        
        contentView.replaceExerciseOnTap = { [weak self] in
            self?.onActionSelected?(.replaceExercise)
        }
        
        contentView.removeExerciseOnTap = { [weak self] in
            self?.onActionSelected?(.deleteExercise)
        }
    }
}
