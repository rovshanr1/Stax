//
//  HomeUiView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 02.12.25.
//

import UIKit
import SnapKit

class HomeUIView: UIView {
    var headerMoreButtonOnTap: (() -> Void)?

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(tableView)
        backgroundColor = .systemBackground
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
