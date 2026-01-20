//
//  TableViewHeader.swift
//  Stax
//
//  Created by Rovshan Rasulov on 03.12.25.
//

import UIKit
import SnapKit

class TableViewHeader: UIView {
    
    var onTapEmptyWorkout: (() -> Void)?
    
    private var button: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "plus")
        config.title = "Start Empty Workout"
        config.baseBackgroundColor = .secondarySystemBackground
        config.baseForegroundColor = .white
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.cornerStyle = .large
        var button = UIButton(type: .system)
        button.configuration = config
        button.contentHorizontalAlignment = .leading
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        addSubview(button)
        
        button.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 12)).priority(999)
        }
        
        
    }
    
    @objc private func didTapButton() {
        onTapEmptyWorkout?()
    }
    
}
