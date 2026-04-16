//
//  ProfileInfoCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 15.04.26.
//

import UIKit
import SnapKit
import Kingfisher

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
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)).priority(999)
        }
        
        profileImage.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
        
        
        profileImage.layer.cornerRadius = 40
    }
    
    func configurationCell(with item: UserModel?, isLoading: Bool) {
        if isLoading {
            userNameText.text = "Kullanıcı Adı Yükleniyor..."
            totalWorkoutsValueText.text = "000"
            userNameText.textColor = .clear
            totalWorkoutsValueText.textColor = .clear
            
            userNameText.backgroundColor = .systemGray5
            totalWorkoutsValueText.backgroundColor = .systemGray5
            profileImage.backgroundColor = .systemGray5
            
            userNameText.layer.masksToBounds = true
            userNameText.layer.cornerRadius = 4
            totalWorkoutsValueText.layer.masksToBounds = true
            totalWorkoutsValueText.layer.cornerRadius = 4
            
            self.layoutIfNeeded()
            
            profileImage.isShimmering = true
            userNameText.isShimmering = true
            totalWorkoutsValueText.isShimmering = true
        } else {
            guard let item = item else { return }
            
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                
                self.profileImage.isShimmering = false
                self.userNameText.isShimmering = false
                self.totalWorkoutsValueText.isShimmering = false
                
                self.userNameText.backgroundColor = .clear
                self.totalWorkoutsValueText.backgroundColor = .clear
                self.profileImage.backgroundColor = .secondarySystemBackground
                
                self.userNameText.textColor = .label
                self.totalWorkoutsValueText.textColor = .label
                
                self.userNameText.text = item.name
                
                if let url = URL(string: item.profileImage ?? "") {
                    self.profileImage.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle.fill"))
                } else {
                    self.profileImage.image = UIImage(systemName: "person.circle.fill")
                    self.profileImage.tintColor = .systemGray
                }
                
            }, completion: nil)
        }
    }
}
