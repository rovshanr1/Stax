//
//  EditProfileView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.04.26.
//

import UIKit
import SnapKit

class EditProfileView: UIView {

    //KeyboardManager
    private var keyboardManager: KeyboardManager?
    
    //Scroll View
    private let scrollView = UIScrollView()
    
    //Container Stack
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 0, left: 0, bottom: 40, right: 0)
        return stack
    }()
    
    //Contents
    let changeProfilePhoto = ChangeProfilePhotoView()
    
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
        scrollView.addSubview(containerStack)
        scrollView.alwaysBounceVertical = true
      
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerStack.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        containerStack.addArrangedSubview(changeProfilePhoto)
        
        keyboardManager = KeyboardManager(scrollView: scrollView)
        scrollView.keyboardDismissMode = .interactive
        setupKeyboardDismissGesture()
        
    }
    
    //MARK: - Keyboard Handling
    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
}
