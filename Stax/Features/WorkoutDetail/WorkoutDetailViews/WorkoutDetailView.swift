//
//  WorkoutDetailView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.03.26.
//

import UIKit
import SnapKit

final class WorkoutDetailView: UIView {
    
    private static func createLayout() -> UICollectionViewCompositionalLayout{
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        return UICollectionViewCompositionalLayout.list(using: config)
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
    
    private func setupUI(){
        addSubview(collectionView)
        backgroundColor = .systemBackground
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
