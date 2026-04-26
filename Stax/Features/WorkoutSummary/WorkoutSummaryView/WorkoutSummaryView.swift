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
    var syncButtonOnTapped: (() -> Void)?
    var discardButtonOnTapped: (() -> Void)?
    
    private var keyboardManager: KeyboardManager?
    
    private let scrollView = UIScrollView()
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 40, right: 0)
        return stack
    }()
    
    let headerView = WorkoutSummaryHeaderView()
    let informationView = InformationView()
    let descriptionView = DescriptionView()
    let footerView = WorkoutSummaryFooterView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
        setupKeyboardHandling()
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
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        containerStackView.addArrangedSubview(headerView)
        containerStackView.addArrangedSubview(informationView)
        containerStackView.addArrangedSubview(descriptionView)
        containerStackView.addArrangedSubview(footerView)
            
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
        
        footerView.syncWithOnTapped = { [weak self] in
            guard let self else {return}
            self.syncButtonOnTapped?()
        }
        
        footerView.discardWorkoutTapped = { [weak self] in
            guard let self else {return}
            self.discardButtonOnTapped?()
        }
    }
    
    //MARK: - Keyboard Handling
    private func setupKeyboardHandling() {
       keyboardManager = KeyboardManager(scrollView: scrollView)
        scrollView.keyboardDismissMode = .interactive
        setupKeyboardDismissGesture()
    }
    
    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
    
    //MARK: - ConfigureMethods
    func configureSyncButton(isEnabled: Bool){
        footerView.configureSyncStatus(isEnabled: isEnabled)
    }
}


