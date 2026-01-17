//
//  SetRowView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 13.01.26.
//

import UIKit
import SnapKit

final class SetRowView: UIView {
    
    var checkboxOnTapped: (() -> Void)?
    
    private var setNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.text = "1"
        label.textAlignment = .center
        return label
    }()
    
    private var previousSets: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.text = "-"
        label.textAlignment = .center
        return label
    }()
    
    private var currentWeight: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.placeholder = "0"
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.borderStyle = .none
        textField.keyboardType = .decimalPad
        textField.returnKeyType = .done
        textField.textAlignment = .center
        return textField
    }()
    
    private let currentReps: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.placeholder = "0"
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.borderStyle = .none
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.textAlignment = .center
        return textField
    }()
    
    private let checkmarkBox: UIButton = {
        let button = UIButton(type: .custom)
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "checkmark.square.fill", withConfiguration: config), for: .normal)
        
        button.setImage(UIImage(systemName: "checkmark.square.fill", withConfiguration: config), for: .selected)
        button.tintColor = .systemGray
        return button
    }()
    
 
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [setNumberLabel, previousSets, currentWeight, currentReps, checkmarkBox])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fill
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI(){
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        setNumberLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.12)
        }
        
        previousSets.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.25)
        }
        
        currentWeight.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.20)
        }
        
        currentReps.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.20)
        }

        
        checkmarkBox.snp.makeConstraints { make in
            make.height.equalTo(40).priority(999)
            make.width.equalToSuperview().multipliedBy(0.15)
        }
        
        
        buttonsActions()
        
    }
    
    func configure(setNumber: Int, previous: String, weight: String?, reps: String?, isDone: Bool){
        setNumberLabel.text = "\(setNumber)"
        previousSets.text = previous
        currentWeight.text = weight
        currentReps.text = reps
        checkmarkBox.isSelected = isDone
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
