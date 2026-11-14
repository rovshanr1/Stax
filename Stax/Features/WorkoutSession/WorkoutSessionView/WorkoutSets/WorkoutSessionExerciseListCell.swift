//
//  WorkoutSessionExerciseListCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.12.25.
//

import UIKit
import SnapKit
import Kingfisher

final class WorkoutSessionExerciseListCell: UICollectionViewCell {
    static let reuseIdentifier = "WorkoutSessionExerciseListCell"
    
    var exerciseMenuOnTapped: (() -> Void)?
    var restTimeOnTapped: ((String) -> Void)?
    
    var onNoteChange: ((String) -> Void)?
    var onNotesHeightChange: (() -> Void)?
    
    var addSetTapped: ((WorkoutExerciseDomainModel) -> Void)?
    var onToggleSetDone: ((String, Double, Int, Bool) -> Void)?
    var deleteSetTapped: ((String) -> Void)?
    
    var onInputFieldFocusChange: ((UIView) -> Void)?
    
    private var currentExerciseID: String?
    
    //MARK: - UI Elements
    private var addNotesTextView = TextView()
    
    private var workoutImageView: CircularImageView = {
        let image = CircularImageView()
        image.clipsToBounds = true
        image.backgroundColor = .secondarySystemBackground
        return image
    }()
    
    private var exerciseName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .tertiaryLabel
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
        label.text = "Rest Timer"
        return label
    }()
    
    private var restTimeNumber: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private var setsView = WorkoutSetsView()
    
    //MARK: - Stack Views
    private lazy var exerciseHeadingStackLeft: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [workoutImageView, exerciseName])
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        exerciseMenuButton.imageView?.removeAllSymbolEffects()
        contentView.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        workoutImageView.kf.cancelDownloadTask()
        workoutImageView.image = nil
        
        currentExerciseID = nil
        setsView.onUpdateSet = nil
        setsView.addSetButtonTapped = nil
    }
    
    //MARK: - Setup UI
    private func setupUI(){
        constraints()
        restStackGesture()
        
        var background = UIBackgroundConfiguration.listCell()
        background.cornerRadius = 12
        self.backgroundConfiguration = background
        
        
        exerciseName.setContentHuggingPriority(.defaultLow, for: .horizontal)
        exerciseName.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        exerciseMenuButton.setContentHuggingPriority(.required, for: .horizontal)
        exerciseMenuButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        exerciseMenuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        
        addNotesTextView.isEditable = true
        addNotesTextView.isSelectable = true
        
    }
    
    //MARK: - Constriants
    private func constraints(){
        contentView.addSubview(mainStack)
        
        mainStack.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 12,
                                                               left: 12,
                                                               bottom: 12,
                                                               right: 12)
            ).priority(999)
        }
        
        exerciseMenuButton.snp.makeConstraints { (make) in
            make.width.equalTo(32)
        }
        
        workoutImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(60)
        }
        
        addNotesTextView.snp.makeConstraints { (make) in
            make.height.greaterThanOrEqualTo(32)
        }
    }
    
    //MARK: - Public method for configure cell
    func configureExerciseCell(with exercise: WorkoutExerciseDomainModel, restDuration: Double?){
        exerciseName.text = exercise.exercise?.name
        currentExerciseID = exercise.id
        
        
        setsView.configureSets(with: exercise.workoutSets)
        
        if let url = URL(string: exercise.exercise?.exerciseImage ?? ""){
            self.workoutImageView.contentMode = .scaleAspectFill
            workoutImageView.kf.setImage(with: url)
        }else{
            self.workoutImageView.contentMode = .center
            
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            self.workoutImageView.image = UIImage(systemName: "dumbbell.fill", withConfiguration: config)
            self.workoutImageView.tintColor = .systemGray
        }
        
        setsView.addSetButtonTapped = { [weak self] in
            self?.addSetTapped?(exercise)
        }
        
        setsView.onUpdateSet = { [weak self] setID, weight, reps, isDone in
            guard let self else {return}
            
            self.onToggleSetDone?(setID, weight, reps, isDone)
        }
        
        setsView.onInputFieldFocus = { [weak self] inputView in
            self?.onInputFieldFocusChange?(inputView)
        }
        
        setsView.onDeleteSet = { [weak self] setID in
            self?.deleteSetTapped?(setID)
        }
        
        restTimeNumber.text = restDuration?.formatDuration() ?? "Off"
    }
    
    func restStackGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(restTimeTapped))
        restTimeStack.addGestureRecognizer(tapGesture)
        restTimeStack.isUserInteractionEnabled = true
    }
    
    func configureTextView(with exercise: String?){
        addNotesTextView.text = exercise
        addNotesTextView.placeholder = "Add notes here..."
        
        addNotesTextView.onTextChange = { [weak self] text in
            guard let self else {return}
            
            self.onNoteChange?(text)
            
        }
        
        addNotesTextView.onHeightChange = { [weak self] in
            self?.onNotesHeightChange?()
        }
    }
    
    //MARK: - Animation
    func shakeSetRow(with setID: String){        
        setsView.shakeSetRow(with: setID)
    }
    
    //MARK: - Actions
    @objc private func menuButtonTapped(){
        exerciseMenuButton.imageView?.addSymbolEffect(.bounce, options: .nonRepeating, animated: true)
        
        exerciseMenuOnTapped?()
    }
    
    @objc private func restTimeTapped(){
        guard let currentExerciseID else { return }
        
        restTimeOnTapped?(currentExerciseID)
    }
}


