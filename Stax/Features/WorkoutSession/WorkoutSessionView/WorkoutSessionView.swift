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
    
    private lazy var footerView: WorkoutSessionFooterView = {
        let view = WorkoutSessionFooterView()
        
        view.onTapAddExerciseButton = { [weak self] in
            self?.addExerciseButtonTapped?()
        }
        
        return view
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        
        collectionView.backgroundColor = .systemBackground
        collectionView.allowsSelection = false
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
        
        return collectionView
    }()
    
    private var currentTimerString: String = "0h 0m 00s"

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
