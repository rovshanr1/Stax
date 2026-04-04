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
    
    private func bindActions(){
        contentView.onTappedSignUp = { [weak self] in
            self?.onTapSignUp?()
        }
    }
}

