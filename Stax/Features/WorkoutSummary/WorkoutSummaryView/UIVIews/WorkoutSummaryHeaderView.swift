//
//  WorkoutSummaryHeaderView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.02.26.
//

import UIKit
import SnapKit

final class WorkoutSummaryHeaderView: UIView {
    
    var titleOnChanged: ((String) -> Void)?
    
    private var summaryTitle: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.placeholder = "Workout title"
        textField.font = .systemFont(ofSize: 24, weight: .bold)
        textField.borderStyle = .none
        textField.keyboardType = .default
        textField.textAlignment = .left
        return textField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(summaryTitle)
        
        summaryTitle.delegate = self
        
        summaryTitle.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    private func actions(){
        summaryTitle.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    func configureHeader(_ summaryTitle: String?){
        self.summaryTitle.text = summaryTitle ?? ""
    }
    
    @objc private func textDidChange(){
        titleOnChanged?(summaryTitle.text ?? "")
    }
}


extension WorkoutSummaryHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
