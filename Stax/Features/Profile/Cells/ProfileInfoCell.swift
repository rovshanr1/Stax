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
    
    //Closures
    var profileImageTapped: (() -> Void)?
    
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
    
    private let totalWorkoutsText: UILabel = {
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
    
    private let totalVolumeText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "Volume"
        return label
    }()
    
    private var totalVolumeValueText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.text = "0"
        return label
    }()
    
    private let totalWorkoutTimeText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "Duration"
        return label
    }()
    
    private var totalWorkoutTimeValueText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.text = "0"
        return label
    }()
    
    private var userBioText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    //StackViews
    private lazy var workoutsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalWorkoutsText, totalWorkoutsValueText])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var totalVolumeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalVolumeText, totalVolumeValueText])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    
    private lazy var totalWorkoutTimeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalWorkoutTimeText, totalWorkoutTimeValueText])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var  combinedStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [workoutsStackView, totalVolumeStackView, totalWorkoutTimeStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var userInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameText, combinedStackView])
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
    
    private lazy var mainStackViewWithBio: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mainStackView, userBioText])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        imageGestureRecognizerTapped()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        contentView.addSubview(mainStackViewWithBio)
        
        mainStackViewWithBio.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)).priority(999)
        }
        
        profileImage.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
        
        
        profileImage.layer.cornerRadius = 40
        
    }
    
    func configurationCell(with item: UserModel?, isLoading: Bool, totalWorkouts: Int, totalVolumes: Double, totalWorkoutTime: Double) {
        
        
        
        if isLoading {
            userNameText.text = "User is loading..."
            totalWorkoutsValueText.text = "000"
            totalVolumeValueText.text = "000"
            totalWorkoutTimeValueText.text = "00:00"
            userBioText.text = ""
            
            userNameText.textColor = .clear
            totalWorkoutsValueText.textColor = .clear
            totalVolumeValueText.textColor = .clear
            totalWorkoutTimeValueText.textColor = .clear
            userBioText.textColor = .clear
            
            userNameText.backgroundColor = .systemGray5
            totalWorkoutsValueText.backgroundColor = .systemGray5
            totalVolumeValueText.backgroundColor = .systemGray5
            totalWorkoutTimeValueText.backgroundColor = .systemGray5
            userBioText.backgroundColor = .systemGray5
            
            userNameText.layer.masksToBounds = true
            userNameText.layer.cornerRadius = 4
            totalWorkoutsValueText.layer.masksToBounds = true
            totalWorkoutsValueText.layer.cornerRadius = 4
            totalVolumeValueText.layer.masksToBounds = true
            totalVolumeValueText.layer.cornerRadius = 4
            totalWorkoutTimeValueText.layer.masksToBounds = true
            totalWorkoutTimeValueText.layer.cornerRadius = 4
            userBioText.layer.masksToBounds = true
            userBioText.layer.cornerRadius = 4
            
            self.layoutIfNeeded()
            
           
            userNameText.isShimmering = true
            totalWorkoutsValueText.isShimmering = true
            totalVolumeValueText.isShimmering = true
            totalWorkoutTimeValueText.isShimmering = true
            userBioText.isShimmering = true
            
        } else {
            guard let item = item else { return }
            
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                
                
                self.userNameText.isShimmering = false
                self.totalWorkoutsValueText.isShimmering = false
                self.totalVolumeValueText.isShimmering = false
                self.totalWorkoutTimeValueText.isShimmering = false
                self.userBioText.isShimmering = false
                
                self.userNameText.backgroundColor = .clear
                self.totalWorkoutsValueText.backgroundColor = .clear
                self.totalVolumeValueText.backgroundColor = .clear
                self.totalWorkoutTimeValueText.backgroundColor = .clear
                self.userBioText.backgroundColor = .clear
                
                self.userNameText.textColor = .label
                self.totalWorkoutsValueText.textColor = .label
                self.totalVolumeValueText.textColor = .label
                self.totalWorkoutTimeValueText.textColor = .label
                self.userBioText.textColor = .label
                
                
                self.userNameText.text = item.name
                self.totalWorkoutsValueText.text = "\(totalWorkouts)"
                self.totalVolumeValueText.text = totalVolumes.formatWeight()
                self.totalWorkoutTimeValueText.text = totalWorkoutTime.formatDurationFromProfile()
                self.userBioText.text = item.bio
                
                
            }, completion: nil)
        }
    }
    
    func configImage(with item: UserModel?, imageIsLoading: Bool){
        if imageIsLoading{
            profileImage.backgroundColor = .systemGray5
            
            self.layoutIfNeeded()
            
            profileImage.isShimmering = true
        }else{
            guard let item = item else { return }
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.profileImage.isShimmering = false
                
                self.profileImage.backgroundColor = .secondarySystemBackground
                
                if let url = URL(string: item.profileImage ?? "") {
                    self.profileImage.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle"))
                } else {
                    self.profileImage.image = UIImage(systemName: "person.circle")
                    self.profileImage.tintColor = .systemGray
                }
            }, completion: nil)
        }
    }
    
    private func imageGestureRecognizerTapped() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTapped))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleImageTapped() {
        profileImageTapped?()
    }
}
