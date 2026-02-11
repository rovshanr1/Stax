//
//  SetRowView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 13.01.26.
//

import UIKit
import SnapKit

final class SetRowView: UIView {
    
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private var panGesture: UIPanGestureRecognizer!
    private var originalCenter: CGPoint = .zero
    
    var onUpdateState: ((Double, Int, Bool) -> Void)?
    var onInputDidBegin: ((UIView) -> Void)?
    var onDelete: (() -> Void)?
    
    private var setNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.text = "1"
        label.textAlignment = .center
        return label
    }()
    
    private var previousSets: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.text = "-"
        label.textAlignment = .center
        return label
    }()
    
    private var currentWeight: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.placeholder = "0"
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.borderStyle = .none
        textField.keyboardType = .decimalPad
        textField.returnKeyType = .done
        textField.textAlignment = .center
        return textField
    }()
    
    private let currentReps: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.placeholder = "0"
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.borderStyle = .none
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.textAlignment = .center
        return textField
    }()
    
    private let checkmarkBox: UIButton = {
        let button = UIButton(type: .custom)
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "checkmark.square", withConfiguration: config), for: .normal)
        
        button.setImage(UIImage(systemName: "checkmark.square.fill", withConfiguration: config), for: .selected)
        button.tintColor = .systemGray
        return button
    }()
    
    private let deleteBackgorundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let deleteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "trash")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let doneOverlayView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        v.isUserInteractionEnabled = false
        v.alpha = 0
        return v
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [setNumberLabel, previousSets, currentWeight, currentReps, checkmarkBox])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        return stackView
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAction()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI(){
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        self.backgroundColor = .clear
        
        addSubview(deleteBackgorundView)
        deleteBackgorundView.addSubview(deleteIcon)
        deleteBackgorundView.isHidden = true
        
        addSubview(contentContainerView)
        contentContainerView.addSubview(doneOverlayView)
        contentContainerView.addSubview(mainStackView)
        
        deleteBackgorundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        deleteIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        contentContainerView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        mainStackView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        doneOverlayView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        setNumberLabel.snp.makeConstraints { make in make.width.equalToSuperview().multipliedBy(0.15) }
        
        previousSets.snp.makeConstraints { make in make.width.equalToSuperview().multipliedBy(0.25) }
        
        currentWeight.snp.makeConstraints { make in make.width.equalToSuperview().multipliedBy(0.20) }
        
        currentReps.snp.makeConstraints { make in make.width.equalToSuperview().multipliedBy(0.20) }
        
        checkmarkBox.snp.makeConstraints { make in
            make.height.equalTo(40).priority(999)
            make.width.equalToSuperview().multipliedBy(0.20)
        }
        
        
    }
    
    func configureSetRow(setNumber: Int, previous: String, weight: Double, reps: Int, isDone: Bool){
        setNumberLabel.text = "\(setNumber)"
        previousSets.text = previous
        
        if weight == 0  {
            currentWeight.text = ""
        }else{
            let isInteger = floor(weight) == weight
            currentWeight.text = isInteger ? "\(Int(weight))" : "\(weight)"
        }
        
        if reps == 0 {
            currentReps.text = ""
        }else{
            currentReps.text = "\(reps)"
        }
        
        checkmarkBox.isSelected = isDone
        
        updateAppearance(isDone: isDone)
        
        deleteIcon.alpha = 0
    }
    
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        panGesture.delegate = self
        contentContainerView.addGestureRecognizer(panGesture)
    }
    
    private func setupAction(){
        checkmarkBox.addTarget(self, action: #selector(checkmarkTapped), for: .touchUpInside)
        
        currentWeight.addTarget(self, action: #selector(handleTextChange), for: .editingDidEnd)
        currentReps.addTarget(self, action: #selector(handleTextChange), for: .editingDidEnd)
        
        currentWeight.addTarget(self, action: #selector(handleInputFocus), for: .editingDidBegin)
        currentReps.addTarget(self, action: #selector(handleInputFocus), for: .editingDidBegin)
    }
    
    private func updateAppearance(isDone: Bool){
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else {return}
            self.contentContainerView.backgroundColor = .secondarySystemBackground 
            self.doneOverlayView.alpha = isDone ? 1 : 0
            self.checkmarkBox.tintColor = isDone ? .systemGreen : .systemGray        }
    }
    
    private func triggerUpdate(){
        let weightText = currentWeight.text?.replacingOccurrences(of: ",", with: ".") ?? ""
        let repsText = currentReps.text ?? ""
        
        let weight = Double(weightText) ?? 0.0
        let reps = Int(repsText) ?? 0
        
        if weight == 0{
            currentWeight.text = ""
           
        } else {
            let isInteger = floor(weight) == weight
            currentWeight.text = isInteger ? "\(Int(weight))" : "\(weight)"
        }
        
        if reps == 0 {
            currentReps.text = ""
        } else {
            currentReps.text = "\(reps)"
        }
        
        let isDone = checkmarkBox.isSelected
        
        onUpdateState?(weight, reps, isDone)
    }
    
    
    @objc private func handleTapGesture(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            originalCenter = contentContainerView.center
            deleteBackgorundView.isHidden = false
        case .changed:
            if translation.x < 0 {
                contentContainerView.center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
                
                let progress = min(1, abs(translation.x) / 100)
                deleteIcon.alpha = progress
            }
            
        case .ended:
            if translation.x < -80 {
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.contentContainerView.center = CGPoint(x: -self.bounds.width, y: self.originalCenter.y)
                }) { _ in
                    
                    self.onDelete?()
                }
            }else{
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations:  {
                    self.contentContainerView.center = self.originalCenter
                }, completion: { _ in
                    self.deleteBackgorundView.isHidden = true
                })
                
            }
        default:
            break
        }
    }
    
    @objc private func checkmarkTapped(){
        checkmarkBox.isSelected.toggle()
        let isDone = checkmarkBox.isSelected
        
        updateAppearance(isDone: isDone)
        
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
        
        triggerUpdate()
    }
    
    @objc private func handleTextChange(){
        triggerUpdate()
    }
    
    @objc private func handleInputFocus(_ textField: UITextField){
        onInputDidBegin?(textField)
    }
    
}


extension SetRowView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer{
            let translation = panGesture.translation(in: self)
            return abs(translation.x) > abs(translation.y)
        }
        return true
    }
}
