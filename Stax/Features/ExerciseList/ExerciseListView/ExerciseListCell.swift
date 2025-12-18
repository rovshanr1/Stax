//
//  ExerciseListCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 17.12.25.
//

import UIKit
import SnapKit

class ExerciseListCell: UITableViewCell {
    static let reuseIdentifier: String = "ExerciseListCell"
    
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
