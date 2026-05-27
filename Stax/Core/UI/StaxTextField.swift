//
//  StaxTextField.swift
//  Stax
//
//  Created by Rovshan Rasulov on 23.05.26.
//

import UIKit
import SnapKit

enum StaxTextFieldType{
    case email
    case password
    case username
}

final class StaxTextField: UITextField {
    private let bottomLineLayer = CALayer()
    
    init(type: StaxTextFieldType, placeholderText: String){
        super.init(frame: .zero)
        
        self.placeholder = placeholderText
        self.borderStyle = .none
        self.textColor = .label
        self.tintColor = .systemBlue
        
        setupBottomLine()
        configureType(for: type)
        addLeftPadding()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bottomLineLayer.frame = CGRect(x: 0,
                                       y: self.bounds.height - 1,
                                       width: self.bounds.width,
                                       height: 1)
    }
    
    private func setupBottomLine() {
        bottomLineLayer.backgroundColor = UIColor.systemGray.cgColor
        self.layer.addSublayer(bottomLineLayer)
    }
    
    private func configureType(for type: StaxTextFieldType){
        
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        
        switch type{
            
        case .email:
            self.keyboardType = .emailAddress
            self.isSecureTextEntry = false
        case .password:
            self.keyboardType = .default
            self.isSecureTextEntry = true
        case .username:
            self.keyboardType = .default
            self.isSecureTextEntry = false
            self.autocapitalizationType = .none
        }
    }
    
    
    private func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
}
