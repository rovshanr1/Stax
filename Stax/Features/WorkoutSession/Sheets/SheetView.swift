//
//  SheetView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.01.26.
//

import UIKit
import SnapKit

class SheetView: UIView {
    
    var replaceExerciseOnTap: (() -> Void)?
    var removeExerciseOnTap: (() -> Void)?
    
    private var replaceExerciseButton: UIButton = {
        let button = UIButton()
        
        let iconConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        var config = UIButton.Configuration.filled()
        
        config.image = UIImage(systemName: "arrow.2.circlepath", withConfiguration: iconConfiguration)
        config.title = "Replace Exercise"
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .secondarySystemBackground
        config.cornerStyle = .medium
        
        button.configuration = config
        return button
    }()
    
    private var removeExerciseButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        var config = UIButton.Configuration.filled()
        
        config.image = UIImage(systemName: "xmark.circle", withConfiguration: configuration)
        config.title = "Remove Exercise"
        config.baseForegroundColor = .systemRed
        config.baseBackgroundColor = .secondarySystemBackground
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.cornerStyle = .medium
        button.configuration = config
        
        return button
    }()
    
    
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [replaceExerciseButton, removeExerciseButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func setupUI() {
        addSubview(mainStackView)
        
        replaceExerciseButton.addTarget(self, action: #selector(replaceExerciseButtonTapped), for: .touchUpInside)
        removeExerciseButton.addTarget(self, action: #selector(removeExerciseButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints(){
        mainStackView.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(20)
        }
    }
    
    @objc private func replaceExerciseButtonTapped(){
        replaceExerciseOnTap?()
    }
    
    @objc private func removeExerciseButtonTapped(){
        removeExerciseOnTap?()
    }
    
}
