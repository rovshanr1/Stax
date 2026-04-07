//
//  LoginView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.04.26.
//

import UIKit
import SnapKit

class LoginView: UIView {
    
    //Closurese
    var onTapSignUp: (() -> Void)?
    var onTapLogin: (() -> Void)?
    var didChangeEmail: ((String) -> Void)?
    var didChangePassword: ((String) -> Void)?
    
    private var keyboardManager: KeyboardManager?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let contentView = LoginContentView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindActions()
        gestureRecignizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(){
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        
        keyboardManager = KeyboardManager(scrollView: scrollView)
    }
    
    private func gestureRecignizer(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }
    
    
    @objc private func dismissKeyboard(){
        self.endEditing(true)
    }
    
    
    private func bindActions(){
        contentView.onTappedSignUp = { [weak self] in
            self?.onTapSignUp?()
        }
        
        contentView.onTappedLogin = { [weak self] in
            self?.onTapLogin?()
        }
        
        contentView.didChangeEmail = { [weak self] email in
            self?.didChangeEmail?(email)
        }
        
        contentView.didChangePassword = { [weak self] password in
            self?.didChangePassword?(password)
        }
    }
    
    func configurationLoginView(isLoading: Bool){
        contentView.isLoginEnabled(isLoading)
    }
    
    func configureLoginButton(isEnabled: Bool){
        contentView.setButtonState(isEnabled)
    }
}

