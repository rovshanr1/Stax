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
    
    var exerciseMenuOnTapped: (() -> Void)?
    var restTimeOnTapped: (() -> Void)?
    
    var onNoteChange: ((String) -> Void)?
    var onNotesHeightChange: (() -> Void)?
    //MARK: - UI Elements
    private var addNotesTextView = TextView()
    
    private var exerciseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .regular)
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
    
    private var restTimeIcon: UIImageView = {
        let imageView = UIImageView()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        imageView.image = UIImage(systemName: "timer", withConfiguration: imageConfig)
        imageView.tintColor = .label
        return imageView
    }()
    
    private var restTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private var restTimeNumber: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private var setsView = WorkoutSetsView()
    
    //MARK: - Stack Views
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
    
    private lazy var restTimeStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [restTimeIcon, restTimeLabel, restTimeNumber])
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 8
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var adNoteAndRestTimeStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [addNotesTextView, restTimeStack])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [exerciseHeadingStack, adNoteAndRestTimeStack, setsView])
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        
        exerciseMenuButton.imageView?.removeAllSymbolEffects()
        
        selectionStyle = .none
        contentView.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup UI
    private func setupUI(){
        constraints()
        
        
        exerciseName.setContentHuggingPriority(.defaultLow, for: .horizontal)
        exerciseName.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        exerciseMenuButton.setContentHuggingPriority(.required, for: .horizontal)
        exerciseMenuButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        exerciseMenuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
      
        
        addNotesTextView.isEditable = true
        addNotesTextView.isSelectable = true
        addNotesTextView.delegate = self
    }
    
    //MARK: - Constriants
    private func constraints(){
        contentView.addSubview(mainStack)
        
        mainStack.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 0,
                                                               left: 12,
                                                               bottom: 0,
                                                               right: 12)).priority(999)
        }
        
        exerciseMenuButton.snp.makeConstraints { (make) in
            make.width.equalTo(32)
        }
        
        exerciseImageView.snp.makeConstraints { (make) in
            make.width.equalTo(32)
        }
        
        addNotesTextView.snp.makeConstraints { (make) in
            make.height.greaterThanOrEqualTo(32)
        }
    }
    
    //MARK: - Public method for configure cell
    func configureExerciseCell(with exercise: Exercise){
        exerciseName.text = exercise.name
        
        restTimeLabel.text = "Rest Time:"
        restTimeNumber.text = "0:00"
        
    }
    
    func configureTextView(with exercise: String?){
        addNotesTextView.text = exercise
        addNotesTextView.placeholder = "Add notes here..."
        
        addNotesTextView.onTextChange = { [weak self] text in
            guard let self else {return}
            
            self.onNoteChange?(text)
            self.onNotesHeightChange?()
        }
        
        
    }
    
    //MARK: - Actions
    @objc private func menuButtonTapped(){
        exerciseMenuButton.imageView?.addSymbolEffect(.bounce, options: .nonRepeating, animated: true)
        
        exerciseMenuOnTapped?()
    }
}


extension WorkoutSessionExerciseListCell: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        addNotesTextView.updatePlaceholder()
        addNotesTextView.onHeightChange? = { [weak self] in
            self?.onNotesHeightChange?()
        }
    }
}
