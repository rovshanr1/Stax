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
    
    var onUpdateSet: ((UUID, Double, Int, Bool) -> Void)?
    var onInputFieldFocus: ((UIView) -> Void)?
    var onDeleteSet: ((UUID) -> Void)?
    
    private var headerView = SetsHeaderView()
    private var footerView = SetsFooterView()
    
    private let setsContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [headerView, setsContainerStackView, footerView])
        stackView.axis = .vertical
        stackView.spacing = 4
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
        
        let existingRows = setsContainerStackView.arrangedSubviews.compactMap { $0 as? SetRowView}
        
        if existingRows.count == sets.count {
            for (index, set) in sets.enumerated() {
                let row = existingRows[index]
                
                row.configureSetRow(
                    setNumber: index + 1,
                    previous: set.previous ?? "-",
                    weight: set.weight,
                    reps: Int(set.reps),
                    isDone: set.isComplated
                )
                
                bindRowClosures(row, set: set)
                
            }
        }else{
            
            setsContainerStackView.arrangedSubviews.forEach {
                setsContainerStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            
            for (index, set) in sets.enumerated() {
                let rowView = SetRowView()
                
                rowView.configureSetRow(
                    setNumber: index + 1,
                    previous: set.previous ?? "-",
                    weight: set.weight,
                    reps: Int(set.reps),
                    isDone: set.isComplated
                )
                
                setsContainerStackView.addArrangedSubview(rowView)
                
                rowView.snp.makeConstraints { make in
                    make.height.equalTo(34)
                }
            }
        }
    }
    
    private func bindRowClosures(_ rowView: SetRowView, set: WorkoutSet){
        rowView.onUpdateState = { [weak self] (weight, reps, isDone) in
            guard let self, let setID = set.id else { return }
            
            self.onUpdateSet?(setID, weight, reps, isDone)
        }
        
        rowView.onInputDidBegin = { [weak self] inputView in
            self?.onInputFieldFocus?(inputView)
        }
        
        rowView.onDelete = { [weak self] in
            guard let self,
                  let setID = set.id
            else { return }
            self.onDeleteSet?(setID)
        }
    }
}
