//
//  HomeTableViewCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 08.03.26.
//

import UIKit
import SnapKit

class HomeTableViewCell: UITableViewCell {
    //Identifier
    static var identifier: String = "HomeTableViewCell"
    
    //Closures
    var headerMoreButtonTapped: (() -> Void)?
    
    //ContentViews
    let headerView = HomeHeaderView()
    
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: ([headerView]))
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupEventHandlers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        contentView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectionStyle = .none
    }
    
    private func setupEventHandlers(){
        
        
        headerView.moreButtonOnTapped = {[weak self] in
            self?.headerMoreButtonTapped?()
        }
    }
}
