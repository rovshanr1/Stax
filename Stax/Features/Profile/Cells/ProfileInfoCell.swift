//
//  ProfileInfoCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 15.04.26.
//

import UIKit
import SnapKit

class ProfileInfoCell: UICollectionViewCell {
    private var profileImage: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private var userNameText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private var totalWorkoutsText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "Workouts"
        return label
    }()
    private var totalWorkoutsValueText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.text = "0"
        return label
    }()
    
    
    
    //StackViews
    
    private lazy var workoutsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalWorkoutsText, totalWorkoutsValueText])
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var userInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameText, workoutsStackView])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [profileImage, userInfoStackView])
        stackView.axis = .horizontal
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
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }
        
        profileImage.snp.makeConstraints { make in
            make.width.height.equalTo(80).priority(999)
        }
        
        profileImage.layer.cornerRadius = 40
    }
    
    func configurationCell(with item: UserModel){
        userNameText.text = item.name
    }
}
