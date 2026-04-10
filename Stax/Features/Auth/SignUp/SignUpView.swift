//
//  SignUpView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.04.26.
//

import UIKit
import SnapKit

class SignUpView: UIView {
    
    var signUpTapped: (() -> Void)?
    var signInTapped: (() -> Void)?
    
    var updateName: ((String) -> Void)?
    var updateEmail: ((String) -> Void)?
    var updatePassword: ((String) -> Void)?
    
    private var keyboardManager: KeyboardManager?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let contentView = SignUpContentView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        gestureRecignizer()
        bindAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(){
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.keyboardDismissMode = .interactive
        
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
    
    private func bindAction(){
        contentView.signInOnTapped = { [weak self] in
            self?.signInTapped?()
        }
        
        contentView.signUpOnTapped = { [weak self] in
            self?.signUpTapped?()
        }
        
        contentView.updateName = { [weak self] text in
            self?.updateName?(text)
        }
        
        contentView.updateEmail = { [weak self] text in
            self?.updateEmail?(text)
        }
        
        contentView.updatePassword = { [weak self] text in
            self?.updatePassword?(text)
        }
    }
    
    func configurationContentView(isLoading: Bool){
        contentView.toggleLoading(isLoading)
    }
    
    func configureButtonSignUp(_ isEnabled: Bool){
        contentView.setButtonState(isEnabled: isEnabled)
    }
    
}
