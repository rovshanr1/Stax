//
//  SettingsView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//

import UIKit
import SnapKit

class SettingsView: UIView {
    private static func createLayout() -> UICollectionViewCompositionalLayout{
        return UICollectionViewCompositionalLayout {_, layoutEnvoriment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
            config.headerMode = .supplementary
            
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvoriment)
            
        }
    }
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemGroupedBackground
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
