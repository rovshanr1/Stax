//
//  WorkoutSummaryMainCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.02.26.
//

import UIKit

class WorkoutSummaryMainCell: UITableViewCell {
    static let reuseIdentifier: String = "WorkoutSummaryMainCell"
    
    private let informationView = InformationView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
