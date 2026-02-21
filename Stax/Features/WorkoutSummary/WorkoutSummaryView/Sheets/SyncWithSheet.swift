//
//  SyncWithSheet.swift
//  Stax
//
//  Created by Rovshan Rasulov on 17.02.26.
//

import UIKit
import SnapKit

class SyncWithSheet: UIViewController {
    
    var syncWithHealth: ((Bool, @escaping (Bool) -> Void) -> Void)?
    
    private let initialSyncState: Bool
    
    init(initialSyncState: Bool){
        self.initialSyncState = initialSyncState
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        syncSwitch.isOn = initialSyncState
        
        syncSwitch.addTarget(self, action: #selector(handleSwitchTapped(_:)), for: .valueChanged)
    }
    
    @objc private func handleSwitchTapped(_ sender: UISwitch){
        let desiredState = sender.isOn
        
        healthLabel.textColor = desiredState ? .label: .secondaryLabel
        
        syncWithHealth?(desiredState) { [weak self] actualState in
            guard let self else { return }
            
            if desiredState != actualState {
                self.syncSwitch.setOn(actualState, animated: true)
                self.healthLabel.textColor = desiredState ? .label: .secondaryLabel
            }
        }
       
    }
}
