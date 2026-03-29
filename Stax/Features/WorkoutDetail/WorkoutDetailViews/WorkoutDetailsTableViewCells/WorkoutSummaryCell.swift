//
//  WorkoutDetailsCollectionViewCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.03.26.
//

import UIKit
import SnapKit

final class WorkoutSummaryCell: UICollectionViewCell {
    let summaryCell = WorkoutDetailHeaderView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(summaryCell)
        
        summaryCell.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 12,
                                                               left: 16,
                                                               bottom: 4,
                                                               right: 16)
            )
        }
    }
    
    func configureWorkoutSummarCell(with item: DetailSummaryItems){
        summaryCell.configureDetailHeader(
            title: item.workoutName,
            time: item.durationString,
            volume: item.volumeString,
            sets: item.setsLabel,
            calories: item.caloriesBurnedString)
    }
}
