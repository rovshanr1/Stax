//
//  SetTableLayout .swift
//  Stax
//
//  Created by Rovshan Rasulov on 09.11.26.
//

import UIKit
import SnapKit

enum SetTableLayout {
    static let horizontalInset: CGFloat = 16
    static let indexColumnWidth: CGFloat = 44
    static let columnSpacing: CGFloat = 8

    @MainActor
    static func makeRow(index: UIView, weight: UIView, reps: UIView) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [index, weight, reps])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = columnSpacing

        index.snp.makeConstraints { $0.width.equalTo(indexColumnWidth) }
        weight.snp.makeConstraints { $0.width.equalTo(reps) }
        return stack
    }
}
