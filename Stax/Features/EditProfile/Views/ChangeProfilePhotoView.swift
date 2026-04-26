//
//  ChangeProfilePhotoView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//

import UIKit
import SnapKit
import Kingfisher

class ChangeProfilePhotoView: UIView {
    //Closures
    var profileImageTapped: (() -> Void)?
    var changeImageOnTapped: (() -> Void)?
    
    private var profileImage: CircularImageView = {
        let imageView = CircularImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private var changeImage: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitle("Change Image", for: .normal)
        button.setTitleColor(.activeItems, for: .normal)
        return button
    }()
    
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [profileImage, changeImage])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageGestureRecognizerTapped()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    
    private func setupView() {
        addSubview(stack)
        
        stack.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12,
                                                             left: 16,
                                                             bottom: 12,
                                                             right: 16)
            )
        }
        
        profileImage.snp.makeConstraints { make in
            make.width.height.equalTo(100)
        }
        
        profileImage.layer.cornerRadius = 50
        
        changeImage.addTarget(self, action: #selector(changeImageTapped), for: .touchUpInside)
    }
    
    func setDraftImage(_ imageData: Data?){
        guard let data = imageData, let image = UIImage(data: data) else{ return }
        
        self.profileImage.image = image
    }
    
    func loadInitialImage(from urlString: String?) {
        if let urlStr = urlString, let url = URL(string: urlStr) {
            self.profileImage.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle"))
        } else {
            self.profileImage.image = UIImage(systemName: "person.circle")
            self.profileImage.tintColor = .systemGray
        }
    }
    
    private func imageGestureRecognizerTapped() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTapped))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGesture)
    }
    
    @objc private func changeImageTapped() {
        changeImageOnTapped?()
    }
    @objc private func handleImageTapped() {
        profileImageTapped?()
    }
}
