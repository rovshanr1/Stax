//
//  ChangeUserNameVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 19.05.26.
//

import UIKit
import Combine

class ChangeUserNameVC: UIViewController {
    
    //callback coordinator
    var onFinish: (() -> Void)?

    //Content View
    private let contentView = EditAccountFormView(
        textFieldtype: .username,
        placeholderText: "add your new username"
    )
    
    //View Model
    private let viewModel: ChangeUserNameVM
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ChangeUserNameVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindVM()
        bindContentView()
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    deinit{
        print("ChangeUserNameVC deinit")
    }
    
    private func bindVM() {
        viewModel.output.isUpdateButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.contentView.configureButton(isEnabled)
            }
            .store(in: &cancellables)
        
        viewModel.output.saveCompletion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.onFinish?()
            }
            .store(in: &cancellables)
        
        viewModel.output.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                guard let self else { return }
                AlertManager.showErrorAlert(on: self, message: messages)
            }
            .store(in: &cancellables)
        
        viewModel.output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.showIndicator(isLoading)
            }
            .store(in: &cancellables)
        
        
    }
    
    
    private func bindContentView(){
        contentView.buttonOnTapped = { [weak self] in
            self?.viewModel.input.updateButtonTapped.send()
        }
        
        contentView.configureTextField(viewModel.initialUserName)
        
        contentView.textFieldOnChanged = {[weak self] text in
            self?.viewModel.input.changeUserName.send(text)
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
