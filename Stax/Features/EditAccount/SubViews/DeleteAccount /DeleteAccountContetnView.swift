//
//  DeleteAccountContetnView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 11.07.26.
//

import UIKit
import SnapKit

final class DeleteAccountContentView: UIView{
    
    var deleteButtonDidTap: (() -> Void)?
    var textFieldDidChange: ((String) -> Void)?
    
    // MARK: - Private UI Elements
    private let passwordTextField = StaxTextField(type: .password, placeholderText: "Enter current password")
    
    private let deleteButton = StaxButton(title: "Wait 10s")
    
    private let warningImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Delete Your Account"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "This action is permanent and cannot be undone. All your workout data, sets, and profile information will be wiped from our servers."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    //MARK: - Stack
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup Method
    private func setupUI(){
        addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(warningImageView)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(descriptionLabel)
        
        mainStackView.addArrangedSubview(passwordTextField)
        mainStackView.setCustomSpacing(32, after: descriptionLabel)
        
        mainStackView.addArrangedSubview(deleteButton)
        mainStackView.setCustomSpacing(16, after: passwordTextField)
        
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        warningImageView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    private func setupAction(){
        deleteButton.addTarget(self, action: #selector(handleDeleteTap), for: .touchUpInside)
        
        passwordTextField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
    }
    
    func updateDeleteButton(isEnabled: Bool, countdownText: String?) {
        deleteButton.isEnabled = isEnabled
        
        if let text = countdownText {
            deleteButton.setTitle(text, for: .normal)
            deleteButton.backgroundColor = .systemGray4
            deleteButton.setTitleColor(.systemGray, for: .normal)
        } else {
            deleteButton.setTitle("Delete Account", for: .normal)
            deleteButton.backgroundColor = .activeItems
            deleteButton.setTitleColor(.white, for: .normal)
        }
    }
    
    
    @objc private func handleDeleteTap(){
        deleteButtonDidTap?()
    }
    
    @objc private func handleTextChange() {
        
        let text = passwordTextField.text ?? ""
        textFieldDidChange?(text)
    }
}
