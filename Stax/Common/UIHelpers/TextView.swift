//
//  TextView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 30.12.25.
//

import UIKit
import SnapKit

class TextView: UITextView {
    
    private let placeholderLabel: UILabel = UILabel()
    
    var onTextChange: ((String) -> Void)?
    var onHeightChange: (() -> Void)?
    
    var placeholder: String? {
        didSet{
            placeholderLabel.text = placeholder
        }
    }
    
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .clear
        font = .systemFont(ofSize: 16)
        textColor = .label
        isScrollEnabled = false
        textContainerInset = .zero
        textContainer.lineBreakMode = .byWordWrapping
        keyboardDismissMode = .interactive
        
        placeholderLabel.font = font
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.numberOfLines = 0
        placeholderLabel.isUserInteractionEnabled = false
        
        addSubview(placeholderLabel)
        
        placeholderLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(frameLayoutGuide).inset(UIEdgeInsets(top: 0, left: 4, bottom: 12, right: 0))
        }
        
    }
    
     func updatePlaceholder() {
        placeholderLabel.isHidden = !text.isEmpty
        onTextChange?(text)
    }
}

