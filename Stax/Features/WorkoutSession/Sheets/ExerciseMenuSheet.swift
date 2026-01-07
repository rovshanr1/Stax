//
//  ExerciseMenuSheet.swift
//  Stax
//
//  Created by Rovshan Rasulov on 08.01.26.
//

import UIKit
import SnapKit



class ExerciseMenuSheet: UIViewController {
    enum Action {
        case deleteExercise
        case replaceExercise
    }
    
    var onActionSelected: ((Action) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSheetUI()
    }
    
    private func setupSheetUI(){
        
    }
}
