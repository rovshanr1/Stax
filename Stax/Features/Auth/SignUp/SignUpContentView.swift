//
//  SignUpContentView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.04.26.
//

import UIKit
import SnapKit

class SignUpContentView: UIView {
    
    var signUpOnTapped: (() -> Void)?
    var signInOnTapped: (() -> Void)?
    
    var updateName: ((String) -> Void)?
    var updateEmail: ((String) -> Void)?
    var updatePassword: ((String) -> Void)?
    
    private let signUp: UILabel = {
        let label = UILabel()
        label.text = "Sign Up"
        label.textColor = .label
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let userNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "username"
        textField.borderStyle = .none
        textField.keyboardType = .default
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        textField.layer.cornerRadius = 12
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        
        
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        iconView.image = UIImage(systemName: "person.fill")
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 50))
        iconView.center = CGPoint(x: 22, y: 25)
        iconContainer.addSubview(iconView)
        
        textField.leftView = iconContainer
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your Email"
        textField.borderStyle = .none
        textField.keyboardType = .emailAddress
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        textField.layer.cornerRadius = 12
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        
        
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        iconView.image = UIImage(systemName: "envelope.fill")
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 50))
        iconView.center = CGPoint(x: 22, y: 25)
        iconContainer.addSubview(iconView)
        
        textField.leftView = iconContainer
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your Password"
        textField.borderStyle = .none
        textField.keyboardType = .default
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        textField.layer.cornerRadius = 12
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        
        
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        iconView.image = UIImage(systemName: "lock.fill")
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 50))
        iconView.center = CGPoint(x: 22, y: 25)
        iconContainer.addSubview(iconView)
        
        textField.leftView = iconContainer
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let signUpButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .activeItems
        config.cornerStyle = .capsule
        config.title = "Sign Up"
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 31)
        
        let button = UIButton()
        button.configuration = config
        return button
    }()
    
    private let alradyHaveAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have an account?"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .regular)
        
        return label
    }()
    
    private let signInButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Sign in"
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .label
        
        let button = UIButton()
        button.configuration = config
        button.contentHorizontalAlignment = .leading
        
        return button
    }()
    
    private lazy var signInContainer: UIView = {
        let view = UIView()
        let stackView = UIStackView(arrangedSubviews: [alradyHaveAccountLabel, signInButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.distribution = .fill
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            
            make.centerX.equalToSuperview()
        }
        
        return view
    }()
    
    
    private lazy var textFieldStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameTextField ,emailTextField, passwordTextField])
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [signUp, textFieldStack, signUpButton, signInContainer])
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.alignment = .fill
        return stackView
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        bindAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        addSubview(mainStackView)
        
        userNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        mainStackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            
            make.leading.trailing.equalToSuperview().inset(24)
            
            make.bottom.equalToSuperview().offset(-20)
            
        }
        
        
        userNameTextField.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
        
        emailTextField.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        signUpButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
        
    }
    
    private func bindAction() {
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        signInButton.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        
        userNameTextField.addTarget(self, action: #selector(userNameTextFieldDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange), for: .editingChanged)
    }
    
    @objc private func handleSignUp() {
        self.signUpOnTapped?()
    }
    
    @objc private func handleSignIn() {
        self.signInOnTapped?()
    }
    
    
    @objc private func userNameTextFieldDidChange(){
        let text = userNameTextField.text ?? ""
        updateName?(text)
    }
    
    @objc private func emailTextFieldDidChange(){
        let text = emailTextField.text ?? ""
        updateEmail?(text)
    }
    
    @objc private func passwordTextFieldDidChange(){
        let text = passwordTextField.text ?? ""
        updatePassword?(text)
    }
    
    func toggleLoading(_ isLoading: Bool) {
        if isLoading{
            signUpButton.isUserInteractionEnabled = false
            signUpButton.configuration?.showsActivityIndicator = true
            signUpButton.configuration?.title = ""
        } else{
            signUpButton.isUserInteractionEnabled = true
            signUpButton.configuration?.showsActivityIndicator = false
            signUpButton.configuration?.title = "Sign Up"
        }
    }
    
    func setButtonState(isEnabled: Bool) {
        signUpButton.isEnabled = isEnabled
        signUpButton.configuration?.baseBackgroundColor = isEnabled ? .activeItems: .systemGray2
    }
    
}


extension SignUpContentView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField{
            emailTextField.becomeFirstResponder()
        }else if textField == emailTextField{
            passwordTextField.becomeFirstResponder( )
        }else if textField == passwordTextField{
            textField.resignFirstResponder( )
        }
        return true
    }
}
