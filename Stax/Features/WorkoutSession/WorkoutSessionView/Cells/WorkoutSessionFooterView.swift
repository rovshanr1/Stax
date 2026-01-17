//
//  WorkoutSessionAddExersiceTableViewCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.12.25.
//

import UIKit
import SnapKit

final class WorkoutSessionFooterView: UIView {
    
    var onTapAddExerciseButton: (() -> Void)?
    
    private var addExerciseButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "plus")
        config.imagePadding = 8
        config.title = "Add Exercise"
        config.baseBackgroundColor = .activeItems
        config.baseForegroundColor = .label
        config.cornerStyle = .large
        var button = UIButton()
        button.configuration = config
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(addExerciseButton)
        
        //AddExerciseButton Height
        addExerciseButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 24,
                                                             left: 16,
                                                             bottom: 24,
                                                             right: 16)
            ).priority(999)

            make.height.equalTo(48)
        }
        
        addExerciseButton.addTarget(self, action: #selector(onTapAddExerciseButtonTapped), for: .touchUpInside)
        
    }
    
    
    @objc private func onTapAddExerciseButtonTapped(){
        self.onTapAddExerciseButton?()
    }
}
