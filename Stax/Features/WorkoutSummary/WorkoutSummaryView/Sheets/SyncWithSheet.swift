//
//  SyncWithSheet.swift
//  Stax
//
//  Created by Rovshan Rasulov on 17.02.26.
//

import UIKit
import SnapKit

class SyncWithSheet: UIViewController {
    
    private var healthLabel: UILabel = {
       let label = UILabel()
        label.text = "Health"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    private var syncSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = .systemBlue
        return switchView
    }()
    
    private let spacer = UIView()
    
    
    private lazy var mainContainer: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [healthLabel, spacer, syncSwitch ])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        view.backgroundColor = .systemBackground
        view.addSubview(mainContainer)
        
        mainContainer.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        
        
        syncSwitch.addTarget(self, action: #selector(handleSwitchTapped(_:)), for: .valueChanged)
    }
    
    @objc private func handleSwitchTapped(_ sender: UISwitch){
        if sender.isOn{
            healthLabel.textColor = .label
        }else{
            healthLabel.textColor = .secondaryLabel
        }
    }
}
