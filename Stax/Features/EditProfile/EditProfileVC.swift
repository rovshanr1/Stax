//
//  EditProfileVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.04.26.
//

import UIKit
import Combine

class EditProfileVC: UIViewController {
    
    //closures
    var didSentEventClosure: ((EditProfileEvent) -> Void)?
    
    //private properties
    private let contentView = EditProfileView()
    private let vm: EditProfileVM
    
    private var cancellables: Set<AnyCancellable> = []
    
    //MARK: - initialization
    init(vm: EditProfileVM){
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        
        setupNavigationBar()
        bindViewModel()
    }
    
    override func loadView() {
        self.view = contentView
    }
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            didSentEventClosure?(.dismiss)
        }
    }
    deinit{
        print("Edit Profile screen deinited")
    }
    
    
    //MARK: - Bind VM
    private func bindViewModel(){
        vm.output.isSaveEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
            }
            .store(in: &cancellables)
        
        vm.output.saveCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.didSentEventClosure?(.saveChanges)
            }
            .store(in: &cancellables)
        
        vm.output.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self else { return }
                AlertManager.showErrorAlert(on: self, message: message)
            }
            .store(in: &cancellables)
        
        vm.output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.showIndicator(isLoading)
            }
            .store(in: &cancellables)
    }
    
    
    //MARK: - Helpers
    private func showIndicator(_ isLoading: Bool){
        if isLoading {
            LoadingManager.shared.show()
            
        } else {
            LoadingManager.shared.hide()
        }
    }
    
    
    
    //MARK: - Save Button
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(handleSaveButton), for: .touchUpInside)
        return button
    }()
    
    private func setupNavigationBar() {
        let barButton = UIBarButtonItem(customView: saveButton)
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc private func handleSaveButton(){
        vm.input.saveButtonTapped.send()
    }
}

