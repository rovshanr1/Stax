//
//  GlobalListCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 15.05.26.
//

import UIKit
import SnapKit

class GlobalListCell: UICollectionViewListCell {
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .white
        view.clipsToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    
    private let accessorySwitch: UISwitch = {
        let accessorySwitch = UISwitch()
        accessorySwitch.isHidden = true
        return accessorySwitch
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
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
    
    
    private func setupUI() {
        //Cell Background
        var backgroundConfig = UIBackgroundConfiguration.listCell()
        backgroundConfig.backgroundColor = .secondarySystemGroupedBackground
        self.backgroundConfiguration = backgroundConfig
        
        iconContainer.addSubview(iconImageView)
        
        mainStackView.addArrangedSubview(iconContainer)
        mainStackView.addArrangedSubview(titleLabel)
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        mainStackView.addArrangedSubview(spacer)
        
        mainStackView.addArrangedSubview(accessorySwitch)
        mainStackView.addArrangedSubview(chevronImageView)
        
        contentView.addSubview(mainStackView)
        
        iconContainer.snp.makeConstraints {make in
            make.width.height.equalTo(30)
        }
        
        iconImageView.snp.makeConstraints {make in
            make.edges.equalToSuperview().inset(4)
        }
        
        mainStackView.snp.makeConstraints {make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8,
                                                             left: 16,
                                                             bottom: 8,
                                                             right: 16)
            )
        }
        
        separatorLayoutGuide.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
        }
    }
    
    func configureiconListCell(title: String,
                               icon: String,
                               iconColor: UIColor,
                               showChevron: Bool,
                               showSwitch: Bool,
                               isSwitchOn: Bool = false,
                               isActionCell: Bool = false
    ){
        
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = iconColor
        
        chevronImageView.isHidden = !showChevron
        accessorySwitch.isHidden = !showSwitch
        accessorySwitch.isOn = isSwitchOn
    }
}
