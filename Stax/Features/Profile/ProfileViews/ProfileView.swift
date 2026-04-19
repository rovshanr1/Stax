//
//  ProfileUIView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 02.12.25.
//

import UIKit
import SnapKit

class ProfileUIView: UIView {
    
    private static func createLayout() -> UICollectionViewCompositionalLayout {
            
            return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
                
                var config = UICollectionLayoutListConfiguration(appearance: .plain)
                config.showsSeparators = false
                
                
                if sectionIndex == 2 {
                    config.headerMode = .supplementary
                } else {
                    config.headerMode = .none
                }
                
                return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }
    }
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        
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
        backgroundColor = .systemBackground
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
