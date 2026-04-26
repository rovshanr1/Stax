//
//  SettingsView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//

import UIKit
import SnapKit

class SettingsView: UIView {
    //closures
    var logoutTapped: (() -> Void)?
    
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @objc private func handleLogout() {
        logoutTapped?()
    }
}
