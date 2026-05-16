//
//  LogoutCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 16.05.26.
//

import UIKit
import SnapKit

class LogoutCell: UICollectionViewListCell {
    private let logoutLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .systemRed
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        var backgroundConfig = UIBackgroundConfiguration.listCell()
        backgroundConfig.backgroundColor = .secondarySystemGroupedBackground
        self.backgroundConfiguration = backgroundConfig
        
        contentView.addSubview(logoutLabel)
        
        logoutLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.height.equalTo(20)
        }
    }
    
    func configureLabel(title: String){
        logoutLabel.text = title
    }
}
