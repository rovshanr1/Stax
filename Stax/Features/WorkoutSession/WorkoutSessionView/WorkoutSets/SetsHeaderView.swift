//
//  SetsHeaderView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 03.01.26.
//

import UIKit
import SnapKit

final class SetsHeaderView: UIView {
    private let setLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        label.text = "SET"
        label.textAlignment = .center
        return label
    }()
    
    private let previousSetsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        label.text = "PREVIUOS"
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private let weightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        label.text = "KG"
        label.textAlignment = .center
        return label
    }()
    
    private let repsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        label.text = "REPS"
        label.textAlignment = .center
        return label
    }()
    
    private let checkmarkHeaderIcon: UIImageView = {
        let imageView = UIImageView()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        imageView.image = UIImage(systemName: "checkmark", withConfiguration: imageConfig)
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            setLabel,
            previousSetsLabel,
            weightLabel,
            repsLabel,
            checkmarkHeaderIcon,
        ])
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 20
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
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        setLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.12)
        }
        
        previousSetsLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.25)
        }
        
        weightLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.20)
        }
        repsLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.20)
        }
        checkmarkHeaderIcon.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.15)
        }
        
    }
  
}
    
  
