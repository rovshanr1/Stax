//
//  WorkoutExerciseHeaderCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.03.26.
//

import UIKit
import SnapKit

final class WorkoutExerciseHeaderCell: UICollectionViewCell {
    private let exerciseInfoView = ExerciseInfoView()
    
    private let setColumnLabel: UILabel = {
        let l = UILabel()
        l.text = "Set"
        l.font = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = .secondaryLabel
        l.textAlignment = .left
        return l
    }()
    
    private let weightRepsColumnLabel: UILabel = {
        let l = UILabel()
        l.text = "Weight & Reps"
        l.font = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = .secondaryLabel
        return l
    }()
    
    
    private lazy var columnsStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [setColumnLabel, weightRepsColumnLabel])
        sv.axis = .horizontal
        sv.spacing = 16
        sv.alignment = .center
        
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 4, right: 0)
        return sv
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [exerciseInfoView, columnsStackView])
        stackView.axis = .vertical
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI(){
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
           
        }
        
        
        setColumnLabel.snp.makeConstraints { make in
            make.width.equalTo(30)
        }
    }
    
    func configureWorkoutExerciseHeader(title: String, image: String?) {
        exerciseInfoView.configure(title: title, image: image)
    }
}
