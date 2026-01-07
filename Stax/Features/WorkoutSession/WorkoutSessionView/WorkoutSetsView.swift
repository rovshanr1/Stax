//
//  WorkoutSetsView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 03.01.26.
//

import UIKit
import SnapKit

class WorkoutSetsView: UIView {
    
    var checkboxOnTapped: (() -> Void)?
    
    //Set Group
    private let setLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        label.text = "SET"
        label.textAlignment = .center
        return label
    }()
    
    private var setNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.text = "1"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var setsLabelGroup: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [setLabel, setNumberLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    // Previous Sets group
    private let previousSetsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        label.text = "PREVIUOS"
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private var previousSets: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.text = "-"
        label.textAlignment = .center
        return label
    }()
    
    lazy var previousSetsLabelGroup: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [previousSetsLabel, previousSets])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    // Weight Label Group
    private let weightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        label.text = "KG"
        label.textAlignment = .center
        return label
    }()
    
    private var currentWeight: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.placeholder = "0"
        textField.font = .systemFont(ofSize: 14, weight: .regular)
        textField.borderStyle = .none
        textField.keyboardType = .decimalPad
        textField.textAlignment = .center
        return textField
    }()
    
    lazy var weightLabelGroup: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [weightLabel, currentWeight])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    // Reps Label Group
    private let repsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        label.text = "REPS"
        label.textAlignment = .center
        return label
    }()
    
    private let currentReps: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.placeholder = "0"
        textField.font = .systemFont(ofSize: 14, weight: .regular)
        textField.borderStyle = .none
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        return textField
    }()
    
    private lazy var repsLabelGroup: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [repsLabel, currentReps])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    // Checkmark Group
    private let checkmarkHeaderIcon: UIImageView = {
        let imageView = UIImageView()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        imageView.image = UIImage(systemName: "checkmark", withConfiguration: imageConfig)
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let checkmarkBox: UIButton = {
        let button = UIButton(type: .custom)
        
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.setImage(UIImage(systemName: "square", withConfiguration: config), for: .normal)
        
        button.setImage(UIImage(systemName: "checkmark.square.fill", withConfiguration: config), for: .selected)
        button.tintColor = .systemBlue
        return button
    }()
    
    private lazy var checkmarkGroup: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [checkmarkHeaderIcon, checkmarkBox])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    //Main StackView
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            setsLabelGroup,
            previousSetsLabelGroup,
            weightLabelGroup,
            repsLabelGroup,
            checkmarkGroup
        ])
        
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        buttonsActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        
        setupConstraints()
    }
    
    private func setupConstraints(){
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        currentWeight.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.width.equalTo(60)
        }
        
        currentReps.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.width.equalTo(60)
        }
        
        previousSets.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.width.equalTo(70)
        }
        
        setNumberLabel.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.width.equalTo(30)
        }
        
        checkmarkBox.snp.makeConstraints { make in
            make.height.equalTo(34)
        }
        
        checkmarkHeaderIcon.snp.makeConstraints { make in
            make.height.equalTo(16)
        }
    }
    
    private func buttonsActions(){
        checkmarkBox.addTarget(self, action: #selector(checkmarkTapped), for: .touchUpInside)
    }
    
    @objc func checkmarkTapped(){
        checkmarkBox.isSelected.toggle()
        
        if checkmarkBox.isSelected{
            checkboxOnTapped?()
        }else{
            
        }
    }
    
}
