//
//  HomeWorkoutView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 22.03.26.
//

import UIKit
import SnapKit
import Kingfisher

final class ExerciseInfoView: UIView {
    private let imageSize: CGFloat = 60.0
    
    private var exerciseNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private var exerciseImage: CircularImageView = {
        let image = CircularImageView()
        image.clipsToBounds = true
        image.backgroundColor = .secondarySystemBackground
        return image
    }()
    
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [exerciseImage, exerciseNameLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
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
            make.width.height.equalTo(imageSize).priority(999)
        }
        
    }
    
    
    func configure(title: String, image: String?){
        exerciseNameLabel.text = title
        
        if let image = image{
            let url = URL(string: image)
            self.exerciseImage.contentMode = .scaleAspectFill
            self.exerciseImage.kf.setImage(with: url)
        }else{
            self.exerciseImage.contentMode = .center
            let configuration = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            self.exerciseImage.image = UIImage(systemName: "dumbbell.fill", withConfiguration: configuration)
            self.exerciseImage.tintColor = .systemGray
            
        }
    }
}
