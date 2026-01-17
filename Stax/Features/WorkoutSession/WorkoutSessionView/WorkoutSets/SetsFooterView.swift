//
//  AddSetButton.swift
//  Stax
//
//  Created by Rovshan Rasulov on 13.01.26.
//

import UIKit
import SnapKit
class SetsFooterView: UIView {

    var onTapAddSetButton: (() -> Void)?
    
    private var addNewSetButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "plus")
        config.imagePadding = 8
        config.title = "Add Set"
        config.baseBackgroundColor = .secondarySystemBackground
        config.baseForegroundColor = .label
        config.cornerStyle = .large
        var button = UIButton()
        button.configuration = config
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
        addSubview(addNewSetButton)
        
        //AddExerciseButton Height
        addNewSetButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)).priority(999)
            make.height.equalTo(48)
        }
        
        addNewSetButton.addTarget(self, action: #selector(onTapAddNewSetButtonTapped), for: .touchUpInside)
        
    }
    
    
    @objc private func onTapAddNewSetButtonTapped(){
        onTapAddSetButton?()
    }
}
