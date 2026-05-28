//
//  EditAccountSubUIView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.05.26.
//

import UIKit
import SnapKit

class EditAccountFormView: UIView {
    
    //closure
    var buttonOnTapped: (() -> Void)?
    var textFieldOnChanged: ((String) -> Void)?
    
    private var keyboardManager: KeyboardManager?
    
    private let scrollView = UIScrollView()
    
    private var textField: StaxTextField
    private let updateButton = StaxButton(title: "Update")
    
  
    
    private lazy var containerStackView: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 40, right: 16)
        return stack
    }()

    init(textFieldtype: StaxTextFieldType, placeholderText: String) {
        
        self.textField = StaxTextField(type: textFieldtype, placeholderText: placeholderText)
        
        super.init(frame: .zero)
        
        backgroundColor = .systemBackground
        
        setupUI()
        stupKeyboardManager()
        setupBindings()
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
        
        containerStackView.addArrangedSubview(textField)
        containerStackView.addArrangedSubview(updateButton)
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        updateButton.snp.makeConstraints { make in
            make.height.equalTo(54)
        }
        
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
    
    //MARK: - Setup Bindings
    private func setupBindings() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
    }
    
   @objc private func textFieldDidChange() {
       let currentText = textField.text ?? ""
       textFieldOnChanged?(currentText)
       
    }
    
    @objc private func updateButtonTapped() {
        buttonOnTapped?()
    }
    
    func configureButton(_ isEnabled: Bool){
            updateButton.isEnabled = isEnabled
    }
    
    func configureTextField(_ text: String){
        if text.isEmpty {
            textField.placeholder = ""
        }else{
            textField.text = text
            textField.placeholder = nil
        }
    }
    
}
