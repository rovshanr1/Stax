//
//  SectionSeparatorView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 25.08.26.
//

import UIKit
import SnapKit

final class SectionSeparatorView: UICollectionReusableView {
    static let elementKind = "sectionSeparator"
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
