//
//  ChangePasswordVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 19.05.26.
//

import UIKit
import Combine

class ChangePasswordVC: UIViewController {
    
    var onFinished: (() -> Void)?

    let viewModel: ChangePasswordVM
    
    let contentView = ChangePasswordFormView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ChangePasswordVM) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindVM()
        bindContenView()
 
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    
    private func bindVM(){
        viewModel.output.isUpdateButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.contentView.configureButton(isEnabled)
            }
            .store(in: &cancellables)
        
        viewModel.output.saveCompletion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.onFinished?()
            }
            .store(in: &cancellables)
        
        viewModel.output.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self else{ return }
                AlertManager.showErrorAlert(on: self, message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.showIndicator(isLoading)
            }
            .store(in: &cancellables)
    }
    
    private func bindContenView(){
        contentView.buttonOnTapped = { [weak self] in
            self?.viewModel.input.updateButtonTapped.send()
        }
        
        
        contentView.newPasswordOnChanged = {[weak self] newPassword in
            self?.viewModel.input.passwordChanged.send(newPassword)
        }
        
        contentView.currentPasswordOnChanged = {[weak self] currentPassword in
            self?.viewModel.input.currentPassword.send(currentPassword)
        }
        
    }
    
    
    
    
    //MARK: - Helpers
    private func showIndicator(_ isLoading: Bool){
        if isLoading {
            LoadingManager.shared.show()
            
        } else {
            LoadingManager.shared.hide()
        }
    }
}
