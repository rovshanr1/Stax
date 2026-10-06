//
//  WorkoutSessionView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.12.25.
//

import UIKit
import SnapKit

final class WorkoutSessionView: UIView {
    
    var addExerciseButtonTapped: (() -> Void)?
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        
        collectionView.backgroundColor = .systemBackground
        collectionView.allowsSelection = false
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
        
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
        backgroundColor = .systemBackground
        addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
}
