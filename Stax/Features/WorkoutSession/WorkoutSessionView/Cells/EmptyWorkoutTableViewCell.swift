//
//  EmptyWorkoutTableViewCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 23.12.25.
//

import UIKit
import SnapKit

final class EmptyWorkoutTableViewCell: UITableViewCell {

    static let reuseIdentifier: String = "EmptyWorkoutTableViewCell"
    
    private let dumbbellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.clipsToBounds = true
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        imageView.image = UIImage(systemName: "dumbbell", withConfiguration: config)
        return imageView
    }()
    
    private let primaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Get started"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Add an exercise to start your workout"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    lazy private var labelStackView: UIStackView = {
        var stackView = UIStackView(arrangedSubviews: [primaryLabel, secondaryLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    lazy private var mainStackView: UIStackView = {
        var stackView = UIStackView(arrangedSubviews: [dumbbellImageView, labelStackView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func setupUI(){
        contentView.addSubview(mainStackView)
        
        dumbbellImageView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.height.equalTo(50)
        }
        
        mainStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 24, left: 16, bottom: 12, right: 16)).priority(999)
        }
        
    }
}
