//
//  SplashView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.04.26.
//

import UIKit
import SnapKit

class SplashView: UIView {
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "StaxLogo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let title: UILabel = {
       let label = UILabel()
        label.text = "Stax"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    let loadingIndicator: UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.hidesWhenStopped = true
            return indicator
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [logoImageView, title, loadingIndicator])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .center
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
        backgroundColor = .systemBackground
        addSubview(stackView)
        
        logoImageView.snp.makeConstraints { make in
                    make.width.height.equalTo(120)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
