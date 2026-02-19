//
//  SyncWithButton.swift
//  Stax
//
//  Created by Rovshan Rasulov on 18.02.26.
//

import UIKit
import SnapKit

class SyncWithButton: UIButton {
    
    private var syncWith: UILabel = {
        let label = UILabel()
        label.text = "Syncing With"
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    private var syncWithHealth: UILabel = {
        let label = UILabel()
        label.text = "Health"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private var chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var spacer = UIView()
    
    
    private lazy var chevronContainer: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [syncWithHealth, chevronImageView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 4
        stackView.alignment = .trailing
        return stackView
    }()
    
    private lazy var mainContainer: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [syncWith, spacer, chevronContainer])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    

    override var isHighlighted: Bool {
        didSet{
            alpha = isHighlighted ? 0.6 : 1.0
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(){
        addSubview(mainContainer)
        
        mainContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        }
        
        mainContainer.isUserInteractionEnabled = false
        
    }
    
    
    func configureSyncWith(isSyncEnabled: Bool){
        if isSyncEnabled{
            syncWithHealth.text = "Health"
            syncWithHealth.textColor = .systemBlue
        }else{
            syncWithHealth.text = "None"
            syncWithHealth.textColor = .tertiaryLabel
        }
    }
}
