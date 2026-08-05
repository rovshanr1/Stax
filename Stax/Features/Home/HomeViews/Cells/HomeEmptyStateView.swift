//
//  HomeEmptyStateCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 16.07.26.
//

import UIKit
import SnapKit

final class HomeEmptyStateView: UIView {
    
    //Closures
    var startWorkoutButtonTapped: (() -> Void)?
    
    //SubViews
    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemGroupedBackground
        view.layer.cornerRadius = 44
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "dumbbell.fill")
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No training yet"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Start tracking your progress with Stax by adding your first workout!"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var startButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Start a Workout"
        config.image = UIImage(systemName: "plus")
        config.imagePadding = 6
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .secondarySystemBackground
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(handleStartButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconBackgroundView, textStackView, startButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(contentStackView)
        iconBackgroundView.addSubview(iconImageView)
        
        contentStackView.setCustomSpacing(28, after: textStackView)
        
        iconBackgroundView.snp.makeConstraints { make in
            make.size.equalTo(88)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(36)
        }
        
        textStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(32)
            make.top.greaterThanOrEqualToSuperview().offset(24)
            make.bottom.lessThanOrEqualToSuperview().offset(-24)
        }
    }
    
    @objc private func handleStartButtonTap() {
        startWorkoutButtonTapped?()
    }
}
