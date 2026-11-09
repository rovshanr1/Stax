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
    
    private let noteIconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        let view = UIImageView(image: UIImage(systemName: "note.text", withConfiguration: config))
        view.tintColor = .secondaryLabel
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let noteLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var noteContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.isHidden = true
        view.addSubview(noteIconView)
        view.addSubview(noteLabel)
        return view
    }()
    
    //MARK: - Column titles
    private let setColumnLabel = WorkoutExerciseHeaderCell.makeColumnLabel("SET", alignment: .left)
    private let weightColumnLabel = WorkoutExerciseHeaderCell.makeColumnLabel("WEIGHT", alignment: .center)
    private let repsColumnLabel = WorkoutExerciseHeaderCell.makeColumnLabel("REPS", alignment: .center)
    
    private lazy var columnsRow = SetTableLayout.makeRow(index: setColumnLabel,
                                                         weight: weightColumnLabel,
                                                         reps: repsColumnLabel)
    
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [exerciseInfoView, noteContainer, columnsRow])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        contentView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12,
                                                             left: SetTableLayout.horizontalInset,
                                                             bottom: 4,
                                                             right: SetTableLayout.horizontalInset))
        }

        noteIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.size.equalTo(16)
        }

        noteLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.equalTo(noteIconView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(12)
        }
    }

    
    func configureWorkoutExerciseHeader(title: String, image: String?, note: String?) {
        exerciseInfoView.configure(title: title, image: image)

        let trimmed = note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        noteLabel.text = trimmed.isEmpty ? nil : trimmed
        noteContainer.isHidden = trimmed.isEmpty
    }
    
    private static func makeColumnLabel(_ text: String, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = alignment
        return label
    }
}
