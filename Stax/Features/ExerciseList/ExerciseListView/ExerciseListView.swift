//
//  ExerciseListView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 17.12.25.
//

import UIKit
import SnapKit

class ExerciseListView: UIView {
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search exercise..."
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    let tableView: UITableView = {
        var tableView = UITableView()
        tableView.register(ExerciseListCell.self, forCellReuseIdentifier: ExerciseListCell.reuseIdentifier)
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 60
        return tableView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(searchBar)
        addSubview(tableView)
        setupConstraints()
        
    }
    
    
    private func setupConstraints(){
        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview().inset(10)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
