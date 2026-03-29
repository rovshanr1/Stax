//
//  WorkoutSetCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.03.26.
//

import UIKit
import SnapKit

final class WorkoutSetCell: UICollectionViewListCell {
    
    private let setIndexLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.textColor = .label
        l.textAlignment = .left
        return l
    }()
    
    private let detailsLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .medium)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [setIndexLabel, detailsLabel, UIView()])
        sv.axis = .horizontal
        sv.spacing = 16
        sv.alignment = .center
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4,
                                                             left: 24,
                                                             bottom: 4,
                                                             right: 16)
            )
        }
        
        setIndexLabel.snp.makeConstraints { make in
            make.width.equalTo(30)
        }
    }
    
    // MARK: - Configuration
    func configureWorkoutDetailSetCell(with item: DetailSetRowItem) {
        
        setIndexLabel.text = "\(item.setIndex)"
        detailsLabel.text = "\(item.weightString) x \(item.repsString)"
        
        
    }
}
