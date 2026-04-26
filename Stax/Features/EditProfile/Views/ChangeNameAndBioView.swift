//
//  ChangeNameAndBioView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//

import UIKit
import SnapKit

class ChangeNameAndBioView: UIView {
    //Closures
    var onNameChanged: ((String) -> Void)?
    var onBioChanged: ((String) -> Void)?
    var onBioHeightChanged: (() -> Void)?
    
    private let publicDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Public profile data"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let name: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "Name"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private var nameTextView: UITextField = {
        let textView = UITextField()
        textView.font = .systemFont(ofSize: 16, weight: .semibold)
        textView.placeholder = "add your Name"
        return textView
        
    }()
    
    private lazy var nameStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [name, nameTextView])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .fill
        return stack
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private let bio: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "Bio"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private var bioTextView: TextView = {
        let textView = TextView()
        textView.font = .systemFont(ofSize: 16, weight: .semibold)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
        
    }()
    
    private lazy var bioStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [bio, bioTextView])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .top
        return stack
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [publicDataLabel, nameStack, separator, bioStack])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(mainStackView)
        
        
        bioTextView.isEditable = true


        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        
        name.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        bio.snp.makeConstraints { make in
            make.width.equalTo(60)
        }

        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
    
    private func setupBindings() {
        nameTextView.addTarget(self, action: #selector(nameTextFieldDidChange), for: .editingChanged)
        
        bioTextView.onTextChange = { [weak self] text in
            guard let self else { return }
            self.onBioChanged?(text)
        }
        
        bioTextView.onHeightChange = { [weak self] in
            guard let self else { return }
            self.onBioHeightChanged?()
        }
    }
    
    @objc private func nameTextFieldDidChange() {
        let currentText = nameTextView.text ?? ""
        onNameChanged?(currentText)
    }
    
    func configure(_ nameText: String, _ bioText: String){
        if nameText.isEmpty{
            nameTextView.placeholder = "add your Name"
        }else{
            nameTextView.text = nameText
            nameTextView.placeholder = ""
        }
       
        if bioText.isEmpty{
            bioTextView.placeholder = "Describe yourself"
        }else{
            bioTextView.text = bioText
            bioTextView.placeholder = ""
        }

    }
}
