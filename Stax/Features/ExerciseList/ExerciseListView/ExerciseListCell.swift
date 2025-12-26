//
//  ExerciseListCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 17.12.25.
//

import UIKit
import SnapKit
import Kingfisher

class ExerciseListCell: UITableViewCell {
    static let reuseIdentifier: String = "ExerciseListCell"
    
    var tappedToDetailButton: (() -> Void)?
    
    private var exerciseImage: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private var exerciseName: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private var muscleGroup: UILabel = {
       let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var arrowIcon: UIImageView = {
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
            let img = UIImage(systemName: "chevron.right", withConfiguration: config)
            let imageView = UIImageView(image: img)
            imageView.tintColor = .tertiaryLabel
            imageView.contentMode = .scaleAspectFit
            return imageView
    }()
    
    lazy var labelStack: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [exerciseName, muscleGroup])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()
    
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [exerciseImage, labelStack, arrowIcon])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        return stackView
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func setupUI() {
        backgroundColor = .none
        selectionStyle = .none
        
        contentView.addSubview(mainStackView)
        
        exerciseImage.snp.makeConstraints{ (make) in
            make.width.height.equalTo(50)
        }
        
        arrowIcon.snp.makeConstraints { (make) in
            make.width.equalTo(12)
        }
        
        mainStackView.snp.makeConstraints{ (make) in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    func configure(with exercise: Exercise) {
        exerciseName.text = exercise.name
        muscleGroup.text = exercise.targetMuscle
        
        //TODO: - Configure Image
        exerciseImage.image = UIImage(systemName: "dumbbell.fill")
    }
}
