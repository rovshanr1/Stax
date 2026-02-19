//
//  DescriptionView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.02.26.
//

import UIKit
import SnapKit

class DescriptionView: UIView {
    //Closures
    var descriptionOnChange: ((String) -> Void)?
    var onNotesHeightChange: (() -> Void)?
    
    // MARK: - UI Components
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "Description"
        return label
    }()
    
    
    private var descriptionTextField: TextView = {
        let tv = TextView()
        tv.placeholder = "How did your workout go?"
        tv.font = .systemFont(ofSize: 16, weight: .regular)
        return tv
    }()
    
    private let separatorView: UIView = {
        let view  = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    //MARK: - Stack
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [descriptionLabel, descriptionTextField, separatorView])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .fill
        return stackView
    }()
    
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(stackView)
       
        descriptionTextField.isEditable = true
        descriptionTextField.isSelectable = true
        
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
        }
    }
    
    private func setupBindings(){
        descriptionTextField.onTextChange = { [weak self] text in
            self?.descriptionOnChange?(text)
        }
        
        descriptionTextField.onHeightChange = { [weak self] in
            self?.onNotesHeightChange?()
        }
    }
    
    func configureDescription(_ text: String?){
        descriptionTextField.text = text ?? ""
        descriptionTextField.updatePlaceholder()
    }
}
                         
  
