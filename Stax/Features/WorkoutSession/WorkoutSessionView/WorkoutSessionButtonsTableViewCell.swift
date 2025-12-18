//
//  WorkoutSessionAddExersiceTableViewCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.12.25.
//

import UIKit
import SnapKit

class WorkoutSessionButtonsTableViewCell: UITableViewCell {
    
    static let reuseIdentifier  = "WorkoutSessionButtonSectionTableViewCell"
    
    var onTapAddExerciseButton: (() -> Void)?
    
    private let dumbbellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.clipsToBounds = true
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        imageView.image = UIImage(systemName: "dumbbell", withConfiguration: config)
        return imageView
    }()
    
    private let primaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Get started"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Add an exercise to start your workout"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
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
    
//    private var settingsButton: UIButton = {
//        var config = UIButton.Configuration.filled()
//        config.title = "Settings"
//        config.baseForegroundColor = .label
//        config.baseBackgroundColor = .secondarySystemBackground
//        config.cornerStyle = .large
//        var button = UIButton()
//        button.configuration = config
//        return button
//    }()
//    
//    private var cancelButton: UIButton = {
//        var config = UIButton.Configuration.filled()
//        config.title = "Cancel"
//        config.baseForegroundColor = .systemRed
//        config.baseBackgroundColor = .secondarySystemBackground
//        config.cornerStyle = .large
//        var button = UIButton()
//        button.configuration = config
//        return button
//    }()
    
    lazy private var labelStackView: UIStackView = {
        var stackView = UIStackView(arrangedSubviews: [primaryLabel, secondaryLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    lazy private var imageViewAndLabelStackView: UIStackView = {
        var stackView = UIStackView(arrangedSubviews: [dumbbellImageView, labelStackView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
//    lazy private var secondaryButtonStackView: UIStackView = {
//        var stackView = UIStackView(arrangedSubviews: [settingsButton, cancelButton])
//        stackView.axis = .horizontal
//        stackView.spacing = 12
//        return stackView
//    }()
    
    lazy private var buttonStackView: UIStackView = {
        var stackView = UIStackView(arrangedSubviews: [addExerciseButton /*, secondaryButtonStackView*/])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    lazy private var mainStackView: UIStackView = {
        var stackView = UIStackView(arrangedSubviews: [imageViewAndLabelStackView, buttonStackView])
        stackView.axis = .vertical
        stackView.spacing = 24
        return stackView
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
        contentView.addSubview(mainStackView)
        
        //AddExerciseButton Height
        addExerciseButton.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        addExerciseButton.addTarget(self, action: #selector(onTapAddExerciseButtonTapped), for: .touchUpInside)
        
//        //SettingButton
//        settingsButton.snp.makeConstraints { (make) in
//            make.height.equalTo(30)
//        }
//        
//        //CancelButton
//        cancelButton.snp.makeConstraints { (make) in
//            make.height.equalTo(30)
//        }
//
        
        //ImageView Height
        dumbbellImageView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.height.equalTo(50)
        }
        
        
        //Constraints
        mainStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 24, left: 12, bottom: 12, right: 12)).priority(999)
        }
    }
    
    
    @objc private func onTapAddExerciseButtonTapped(){
        self.onTapAddExerciseButton?()
    }
}
