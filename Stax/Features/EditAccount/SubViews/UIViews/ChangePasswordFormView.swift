//
//  ChangePasswordFormView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.05.26.
//

import UIKit
import SnapKit

class ChangePasswordFormView: UIView {
    //closure
    var buttonOnTapped: (() -> Void)?
    var currentPasswordOnChanged: ((String) -> Void)?
    var newPasswordOnChanged: ((String) -> Void)?
    
    private var keyboardManager: KeyboardManager?
    
    private let scrollView = UIScrollView()
    
    
    
    private var currentPasswordTextField = StaxTextField(type: .password, placeholderText: "add the current password here.")
    
    private var newPasswordTextField = StaxTextField(type: .password, placeholderText: "add the new password here.")
    
    private let updateButton = StaxButton(title: "Update")
    
    
    private lazy var containerStackView: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 40, right: 16)
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(containerStackView)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        containerStackView.addArrangedSubview(currentPasswordTextField)
        containerStackView.addArrangedSubview(newPasswordTextField)
        containerStackView.addArrangedSubview(updateButton)
        
        
        currentPasswordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        newPasswordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        
        updateButton.snp.makeConstraints { make in
            make.height.equalTo(54)
        }
        
        stupKeyboardManager()
        setupBindings()
        
    }
    
    //MARK: - Keyboard Handling
    private func stupKeyboardManager(){
        keyboardManager = KeyboardManager(scrollView: scrollView)
        scrollView.keyboardDismissMode = .interactive
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
    
    
    private func setupBindings() {
        currentPasswordTextField.addTarget(self, action: #selector(currentPasswordTextFieldDidChange), for: .editingChanged)
        
        newPasswordTextField.addTarget(self, action: #selector(newPasswordTextFieldDidChange), for: .editingChanged)
        
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
    }
    
    
    @objc private func currentPasswordTextFieldDidChange() {
        let currentPassword = currentPasswordTextField.text ?? ""
        currentPasswordOnChanged?(currentPassword)
    }
    
    @objc private func newPasswordTextFieldDidChange() {
        let newPassword = newPasswordTextField.text ?? ""
        newPasswordOnChanged?(newPassword)
    }
    
    
    @objc private func updateButtonTapped() {
        buttonOnTapped?()
    }
    
    
    func configureButton(_ isEnabled: Bool){
            updateButton.isEnabled = isEnabled
    }
}
