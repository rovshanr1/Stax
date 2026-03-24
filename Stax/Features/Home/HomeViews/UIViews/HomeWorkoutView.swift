//
//  HomeWorkoutView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 22.03.26.
//

import UIKit
import SnapKit
import Kingfisher

class HomeWorkoutView: UIView {
    
    private var exerciseNameLabel: UILabel = {
       let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private var exerciseImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .secondarySystemBackground
        return image
    }()
    

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [exerciseImage, exerciseNameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stackView])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        exerciseImage.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
        
        exerciseImage.layer.cornerRadius = 30
    }
    
    
    func configure(title: String, image: String?){
        exerciseNameLabel.text = title
    }

}
