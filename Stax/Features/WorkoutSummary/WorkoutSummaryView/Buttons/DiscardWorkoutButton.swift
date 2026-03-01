//
//  DiscardWorkoutButton.swift
//  Stax
//
//  Created by Rovshan Rasulov on 19.02.26.
//

import UIKit
import SnapKit

class DiscardWorkoutButton: UIButton {
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.text = "Discard Workout"
        label.textColor = .systemRed
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        }
    }
    
}
