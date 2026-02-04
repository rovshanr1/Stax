//
//  WorkoutSummaryView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.01.26.
//

import UIKit
import SnapKit

final class WorkoutSummaryView: UIView {
    var titleOnChanged: ((String) -> Void)?
    var descriptionOnChange: ((String) -> Void)?
    
    private let scrollView = UIScrollView()
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    let headerView = WorkoutSummaryHeaderView()
    let informationView = InformationView()
    let descriptionView = DescriptionView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(scrollView)
        scrollView.addSubview(containerStackView)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
     
        containerStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        containerStackView.addArrangedSubview(headerView)
        containerStackView.addArrangedSubview(informationView)
        containerStackView.addArrangedSubview(descriptionView)
        
       
    }
    
    //MARK: - Binding events
    private func bind() {
        headerView.titleOnChanged = { [weak self] title in
            guard let self else {return}
            self.titleOnChanged?(title)
        }
        
        descriptionView.descriptionOnChange = { [weak self] description in
            guard let self else {return}
            self.descriptionOnChange?(description)
        }
    }
    
    //MARK: - Keyboard Handling
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            
            
        let bottomInset = keyboardFrame.height
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.verticalScrollIndicatorInsets = .zero
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self)
    }
}


