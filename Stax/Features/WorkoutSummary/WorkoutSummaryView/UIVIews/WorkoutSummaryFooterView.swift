//
//  WorkoutSummaryFooterView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 17.02.26.
//

import UIKit
import SnapKit

class WorkoutSummaryFooterView: UIView {
    
    var syncWithOnTapped: (() -> Void)?
    var discardWorkoutTapped: (() -> Void)?
    
    private let syncWithButton = SyncWithButton()
    private let discardWorkoutButton = DiscardWorkoutButton()

    private let separatorView: UIView = {
        let view  = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [syncWithButton, separatorView, discardWorkoutButton])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()
   
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI(){
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        
       
        
        syncWithButton.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(44)
        }
        
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
        }
        
        syncWithButton.addTarget(self, action: #selector(syncWithTapped), for: .touchUpInside)
        discardWorkoutButton.addTarget(self, action: #selector(discardButtonTapped), for: .touchUpInside)
    }
    
    func configureSyncStatus(isEnabled: Bool){
        syncWithButton.configureSyncWith(isSyncEnabled: isEnabled)
    }
    
    
    @objc private func syncWithTapped(){
        syncWithOnTapped?()
    }
    
    @objc private func discardButtonTapped(){
        discardWorkoutTapped?()
    }
}
