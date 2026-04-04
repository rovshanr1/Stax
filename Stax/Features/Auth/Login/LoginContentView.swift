//
//  LoginView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 03.04.26.
//

import UIKit
import SnapKit

class LoginContentView: UIView {
    
    private let loginText: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.textColor = .label
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
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
    
    private let spacerForForgotPassword: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        return view
    }()
    
    private let forgotPassword: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Forgot Password?"
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .secondaryLabel
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        
        let button = UIButton()
        button.configuration = config
        button.contentHorizontalAlignment = .trailing
        
        return button
    }()
    
    private let loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Login"
        config.baseBackgroundColor = .activeItems
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 31)
        
        let button = UIButton()
        button.configuration = config
        return button
    }()
    
    
    private lazy var textFieldStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, forgotPassword])
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [loginText, textFieldStack, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.alignment = .fill
        return stackView
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            
            make.leading.trailing.equalToSuperview().inset(24)
            
            make.bottom.equalToSuperview().offset(-20)
            
        }
        
        emailTextField.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
    }
    
    
}
