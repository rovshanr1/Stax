//
//  WorkoutSetsView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 13.01.26.
//

import UIKit
import SnapKit

class WorkoutSetsView: UIView {
    
    var addSetButtonTapped: (() -> Void)?
    
    private var headerView = SetsHeaderView()
    private var footerView = SetsFooterView()

    private let setsContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [headerView, setsContainerStackView, footerView])
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(mainStack)
        
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        footerView.onTapAddSetButton = { [weak self] in
            self?.addSetButtonTapped?()
        }
    }
    
    //MARK: - Configuration
    
    func configuartionSets(with sets: [WorkoutSet]) {
        setsContainerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, set) in sets.enumerated() {
            let rowView = SetRowView()
                
            rowView.configure(setNumber: index + 1,
                              previous: "-",
                              weight: set.weight > 0 ? "\(set.weight)kg" : "",
                              reps: set.reps > 0 ? "\(set.reps)" : "",
                              isDone: set.isComplated
            )
            
            setsContainerStackView.addArrangedSubview(rowView)
            
            rowView.snp.makeConstraints { make in
                make.height.equalTo(34)
            }
        }
        
    }
}
