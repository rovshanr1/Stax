//
//  DividerCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 27.12.25.
//

import UIKit
import SnapKit

class DividerCell: UITableViewCell {
    
    static let reuseIdentifier = "DividerUIView"
    
    private let seperatorView: UIView = {
        let view  = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSeperator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupSeperator(){
        addSubview(seperatorView)
        
        seperatorView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 0, left: 12, bottom: 12, right: 12))
            make.height.equalTo(1)
        }
    }

}
