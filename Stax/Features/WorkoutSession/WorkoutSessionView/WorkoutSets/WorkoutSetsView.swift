//
//  WorkoutSetsView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 13.01.26.
//

import UIKit
import SnapKit


final class WorkoutSetsView: UIView {
    
    var addSetButtonTapped: (() -> Void)?
    
    var onUpdateSet: ((String, Double, Int, Bool) -> Void)?
    var onInputFieldFocus: ((UIView) -> Void)?
    var onDeleteSet: ((String) -> Void)?
    
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
    
    func configureSets(with sets: [WorkoutSetDomainModel]) {
        
        var existingRowsByID: [String: SetRowView] = [:]
        
        for view in setsContainerStackView.arrangedSubviews {
            if let row = view as? SetRowView, let id = row.currentSetID {
                existingRowsByID[id] = row
            }
        }
        
        let newIDs = Set(sets.map {$0.id})
        for (id, row) in existingRowsByID where !newIDs.contains(id) {
            setsContainerStackView.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
        
        
        for (index, set) in sets.enumerated() {
            let rowView = existingRowsByID[set.id] ?? SetRowView()
            
            if existingRowsByID[set.id] == nil {
                rowView.snp.makeConstraints { make in
                    make.height.equalTo(34)
                }
            }
            
            rowView.currentSetID = set.id
            setsContainerStackView.insertArrangedSubview(rowView, at: index)
            
            rowView.configureSetRow(
                setNumber: index + 1,
                previous: set.previous,
                weight: set.weight,
                reps: Int(set.reps),
                isDone: set.isCompleted
            )
            
            bindRowClosures(rowView, set: set)
        }
    }
    
    private func bindRowClosures(_ rowView: SetRowView, set: WorkoutSetDomainModel){
        rowView.onUpdateState = { [weak self] (weight, reps, isDone) in
            guard let self else { return }
            
            let setID = set.id
            self.onUpdateSet?(setID, weight, reps, isDone)
        }
        
        rowView.onInputDidBegin = { [weak self] inputView in
            self?.onInputFieldFocus?(inputView)
        }
        
        rowView.onDelete = { [weak self] in
            guard let self else { return }
            
            let setID = set.id
            self.onDeleteSet?(setID)
        }
    }
    
    func shakeSetRow(with setID: String){
      
        for view in setsContainerStackView.arrangedSubviews{
            if let setRow = view as? SetRowView,
               setRow.currentSetID == setID{
                
                setRow.showErrorAnimation()
                break
            }
        }
    }
}
