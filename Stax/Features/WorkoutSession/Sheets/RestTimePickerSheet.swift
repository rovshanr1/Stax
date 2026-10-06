//
//  RestTimePickerSheet.swift
//  Stax
//
//  Created by Rovshan Rasulov on 17.09.26.
//

import UIKit
import SnapKit

final class RestTimePickerSheet: UIViewController {

    var onDurationSelected: ((Double) -> Void)?
    
    private let durations: [Double] = [0, 15, 30, 45, 60, 90, 120, 150, 180, 240, 300]
    private var selectedDuration: Double
    private let hadDuration: Bool
    private let exerciseName: String

    init(exerciseName: String, initialDuration: Double? = nil) {
          self.exerciseName = exerciseName
          self.selectedDuration = initialDuration ?? 0
          self.hadDuration = (initialDuration ?? 0) > 0
          super.init(nibName: nil, bundle: nil)
}
      
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rest Timer"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var exerciseNameLabel: UILabel = {
          let label = UILabel()
          label.text = exerciseName
          label.font = .systemFont(ofSize: 15, weight: .regular)
          label.textColor = .secondaryLabel
          label.textAlignment = .center
          label.numberOfLines = 2
          return label
    }()
    
    private let separator: UIView = {
         let view = UIView()
         view.backgroundColor = .separator
         return view
     }()
    
    private let pickerView = UIPickerView()

    
    private let startButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Start Rest Timer"
        config.baseBackgroundColor = .activeItems
        config.baseForegroundColor = .label
        config.cornerStyle = .large
        return UIButton(configuration: config)
    }()
    
    private lazy var headerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, exerciseNameLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private lazy var mainStack: UIStackView = {
         let stack = UIStackView(arrangedSubviews: [headerStack, separator, pickerView, startButton])
         stack.axis = .vertical
         stack.spacing = 16
         return stack
     }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        initialization()
        
    }

    private func initialization(){
        pickerView.delegate = self
        pickerView.dataSource = self
        
        if let initialIndex = durations.firstIndex(of: selectedDuration) {
            pickerView.selectRow(initialIndex, inComponent: 0, animated: false)
        }
        
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
    }
    
    private func setupUI(){
        view.backgroundColor = .systemBackground
        view.addSubview(mainStack)
        
        mainStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        startButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
      
        
    }
    
    
    private func updateButton() {
        var config = startButton.configuration
        
        if selectedDuration > 0 {
            config?.title = "Start Rest Timer"
            startButton.isEnabled = true
        } else if hadDuration {
            config?.title = "Turn Off Rest Timer"
            startButton.isEnabled = true
        } else {
            config?.title = "Start Rest Timer"
            startButton.isEnabled = false
        }
        
        startButton.configuration = config
    }
    
    @objc private func startTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.onDurationSelected?(self.selectedDuration)
        }
    }
}

extension RestTimePickerSheet: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        durations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let value = durations[row]
        return value == 0 ? "Off" : value.formatDuration()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDuration = durations[row]
        updateButton()
    }
}
