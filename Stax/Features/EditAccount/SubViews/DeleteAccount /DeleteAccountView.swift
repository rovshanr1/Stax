//
//  DeleteAccountView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 20.06.26.
//

import UIKit
import SnapKit

class DeleteAccountView: UIView {
    
    private var keyboardManager: KeyboardManager?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    let deleteContentView = DeleteAccountContentView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI(){
        backgroundColor = .systemBackground
        
        addSubview(scrollView)
        scrollView.addSubview(deleteContentView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        deleteContentView.snp.makeConstraints { (make) in
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
    
}
