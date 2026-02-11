//
//  InformationView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.02.26.
//

import UIKit
import SnapKit

class InformationView: UIView {
    
    // MARK: - UI Components
    private let durationLabel: UILabel = makeTitleLabel(text: "Duration")
    private let volumeLabel: UILabel = makeTitleLabel(text: "Volume")
    private let setsLabel: UILabel = makeTitleLabel(text: "Sets")
    
    private let timerValue: UILabel = makeValueLabel(text: "0s")
    private let volumeValue: UILabel = makeValueLabel(text: "0 kg")
    private let setsValue: UILabel = makeValueLabel(text: "0")
    
    private let separatorView: UIView = {
        let view  = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private let secondSeparatorView: UIView = {
        let view  = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private let whenLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "Complated"
        return label
    }()
    
    private let dateValue: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .right
        return label
        
    }()
    
    //MARK: - Stacks
    private lazy var statsLabelsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [durationLabel, volumeLabel, setsLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()
    
    private lazy var statsValuesStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timerValue, volumeValue, setsValue])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()
    
    private lazy var statsContainerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statsLabelsStack, statsValuesStack])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private lazy var dateStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [whenLabel, dateValue])
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var rootStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statsContainerStack, separatorView, dateStack, secondSeparatorView])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(rootStack)
        
        rootStack.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 0, right: 16))
        }
        
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
        }
        
        secondSeparatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
    
    func configureInformations(duration: String, volume: Double, sets: Int, date: Date){
        timerValue.text = duration
        volumeValue.text = String(format: "%.1f kg", volume)
        setsValue.text = "\(sets)"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateValue.text = formatter.string(from: date)
    }
    
    
    //MARK: - Helpers
    private static func makeTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = text
        label.textAlignment = .left
        return label
    }
    
    private static func makeValueLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = text
        label.textAlignment = .left
        return label
    }
}
