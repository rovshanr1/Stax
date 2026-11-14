//
//  WorkoutSetCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.03.26.
//

import UIKit
import SnapKit

final class WorkoutSetCell: UICollectionViewListCell {
    
    private let indexLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let indexBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let indexColumn = UIView()
    
    private let weightLabel = WorkoutSetCell.makeValueLabel()
    private let repsLabel = WorkoutSetCell.makeValueLabel()
    
    private lazy var rowStack = SetTableLayout.makeRow(index: indexColumn,
                                                       weight: weightLabel,
                                                       reps: repsLabel)

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(rowStack)
        indexColumn.addSubview(indexBadge)
        indexBadge.addSubview(indexLabel)
        
        rowStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6,
                                                             left: SetTableLayout.horizontalInset,
                                                             bottom: 6,
                                                             right: SetTableLayout.horizontalInset))
        }

        indexBadge.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.size.equalTo(28)
        }
        
        indexLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    func configureWorkoutDetailSetCell(with item: DetailSetRowItem) {
        indexLabel.text = "\(item.setIndex)"
        weightLabel.text = item.weightString
        repsLabel.text = item.repsString
    }

    
    //MARK: - Factory
    private static func makeValueLabel() -> UILabel {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }
}
