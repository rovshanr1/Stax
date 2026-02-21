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
    
    private let syncWithButton = SyncWithButton()

    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [syncWithButton])
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
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 4, right: 16))
        }
        
        syncWithButton.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(44)
        }
        
        syncWithButton.addTarget(self, action: #selector(syncWithTapped), for: .touchUpInside)
        
    }
    
    func configureSyncStatus(isEnabled: Bool){
        syncWithButton.configureSyncWith(isSyncEnabled: isEnabled)
    }
    
    
    @objc private func syncWithTapped(){
        syncWithOnTapped?()
    }
}
