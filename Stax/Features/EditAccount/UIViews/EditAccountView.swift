//
//  EditAccountView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 17.05.26.
//

import UIKit
import SnapKit

class EditAccountView: UIView {
    
    private static func createLayout() -> UICollectionViewCompositionalLayout{
        return UICollectionViewCompositionalLayout { _, layoutEnvoriment in
            let confictLayout = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            
            return NSCollectionLayoutSection.list(using: confictLayout, layoutEnvironment: layoutEnvoriment)
        }
    }
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemGroupedBackground
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
