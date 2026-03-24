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
    var workoutDetailsTapped: ((String) -> Void)?
    
    //ContentViews
    let headerView = HomeHeaderView()
    
    private var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private var thickSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        return view
    }()
    
    private var moreExercisesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .tertiaryLabel
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var exerciseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: ([headerView, separatorView, exerciseStackView,  moreExercisesLabel]))
        stackView.axis = .vertical
        stackView.spacing = 12
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
        contentView.addSubview(thickSeparatorView)
        contentView.addSubview(mainStackView)

        thickSeparatorView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(15)
        }
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(16)
            
            make.bottom.equalTo(thickSeparatorView.snp.top).offset(-16).priority(999)
        }
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        selectionStyle = .none
    }
    
    private func setupEventHandlers(){
        headerView.moreButtonOnTapped = {[weak self] in
            self?.headerMoreButtonTapped?()
        }
    }
    
    func configureExercise(exercise: [ExerciseSummaryItem], moreText: String?) {
        exerciseStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for exerciseItem in exercise{
            let exerciseView = HomeWorkoutView()
            exerciseView.configure(title: exerciseItem.exerciseName, image: exerciseItem.imageURl)
            
            exerciseStackView.addArrangedSubview(exerciseView)
        }
        
        if let text = moreText {
            moreExercisesLabel.text = text
            moreExercisesLabel.isHidden = false
        }else{
            moreExercisesLabel.isHidden = true
        }
    }
}
