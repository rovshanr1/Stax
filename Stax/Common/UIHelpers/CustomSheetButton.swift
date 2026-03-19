//
//  MoreSheetView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 12.03.26.
//

import UIKit
import SnapKit

class CustomSheetButton: UIView {
    //Closures
    var buttonTapped: (() -> Void)?
    
    //Content
    private var customActionButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI(){
        addSubview(customActionButton)
        self.backgroundColor = .secondarySystemGroupedBackground
        
        customActionButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(56)
        }
        
        customActionButton.addTarget(self, action: #selector(buttonTappedAction), for: .touchUpInside)
    }
    
    func configButton(title: String, iconName: String, textColor: UIColor){
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: iconName, withConfiguration: imageConfiguration)
        config.title = title
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = textColor
        config.baseBackgroundColor = .secondarySystemGroupedBackground
        
        customActionButton.configuration = config
        customActionButton.contentHorizontalAlignment = .leading
        
    }
    
    @objc private func buttonTappedAction(){
        buttonTapped?()
    }
}
