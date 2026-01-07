//
//  WorkoutSessionAddExersiceTableViewCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.12.25.
//

import UIKit
import SnapKit

class AddExerciseButtonTableViewCell: UITableViewCell {
    
    static let reuseIdentifier  = "AddExerciseButtonTableViewCell"
    
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
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        contentView.addSubview(addExerciseButton)
        
        //AddExerciseButton Height
        addExerciseButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 24, left: 16, bottom: 12, right: 16)).priority(999)
        }
        
        addExerciseButton.addTarget(self, action: #selector(onTapAddExerciseButtonTapped), for: .touchUpInside)
        
    }
    
    
    @objc private func onTapAddExerciseButtonTapped(){
        self.onTapAddExerciseButton?()
    }
}
