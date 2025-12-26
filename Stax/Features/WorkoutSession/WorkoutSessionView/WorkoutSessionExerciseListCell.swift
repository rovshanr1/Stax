//
//  WorkoutSessionExerciseListCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.12.25.
//

import UIKit
import SnapKit

class WorkoutSessionExerciseListCell: UITableViewCell {

    static let reuseIdentifier = "WorkoutSessionExerciseListCell"
    
    var exerciseMenuTapped: (() -> Void)?
    
    private var exerciseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
        imageView.image = UIImage(systemName: "dumbbell", withConfiguration: config)
        imageView.tintColor = .label
        return imageView
    }()
    
    private var exerciseName: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private var exerciseMenuButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        
        config.image = UIImage(systemName: "ellipsis", withConfiguration: imageConfig)
        config.imagePadding = 8
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .label
        
        button.configuration = config
        return button
    }()
//    
//    private var addNote: UITextField{
//        
//    }
    
    private lazy var exerciseHeadingStackLeft: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [exerciseImageView, exerciseName])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var exerciseHeadingStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [exerciseHeadingStackLeft, exerciseMenuButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        exerciseMenuButton.imageView?.removeAllSymbolEffects()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        exerciseName.setContentHuggingPriority(.defaultLow, for: .horizontal)
        exerciseName.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        exerciseMenuButton.setContentHuggingPriority(.required, for: .horizontal)
        exerciseMenuButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        contentView.addSubview(exerciseHeadingStack)
        
        exerciseHeadingStack.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(16).priority(999)
        }
        
        exerciseMenuButton.snp.makeConstraints { (make) in
            make.width.equalTo(32)
        }
        
        exerciseImageView.snp.makeConstraints { (make) in
            make.width.equalTo(32)
        }
        
        
        exerciseMenuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
    }
    
    func configureExerciseCell(with exercise: Exercise){
        exerciseName.text = exercise.name
    }

    
    @objc private func menuButtonTapped(){
        exerciseMenuButton.imageView?.addSymbolEffect(.bounce, options: .nonRepeating, animated: true)
        
        exerciseMenuTapped?()
    }
}
