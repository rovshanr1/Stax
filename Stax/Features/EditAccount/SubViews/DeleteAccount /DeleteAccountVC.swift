//
//  DeleteAccountVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 03.06.26.
//

import UIKit
import Combine

class DeleteAccountVC: UIViewController {
    var onDismiss: (() -> Void)?
    var onDeletionSuccess: (() -> Void)?
    
    private let viewModel: DeleteAccountVM
    private let contentView = DeleteAccountView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: DeleteAccountVM) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupNavigationBar()
        bindAction()
    }
    
    
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewModel.input.viewDidAppear.send(())
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.viewModel.input.viewDidDisappear.send(())
    }
    
    deinit{
        print("dismissed delete account view")
    }
    
    //MARK: - Bind ViewModel
    private func bindViewModel() {
        viewModel.output.isDeleteButtonEnabled
            .combineLatest(viewModel.output.countdownText)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled, countdownText in
                guard let self else {return}
                
                self.contentView.deleteContentView.updateDeleteButton(isEnabled: isEnabled, countdownText: countdownText)
            }
            .store(in: &cancellables)
        
        viewModel.output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                self.showIndicator(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.output.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self else { return }
                
                AlertManager.showErrorAlert(on: self, message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.isDeleteSuccessful
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                self.onDeletionSuccess?()
            }
            .store(in: &cancellables)
            
    }
    
    //MARK: - Binde Content View Action
    private func bindAction(){
        contentView.deleteContentView.textFieldDidChange = { [weak self] text in
            self?.viewModel.input.currentPassword.send(text)
        }
        
        contentView.deleteContentView.deleteButtonDidTap = { [weak self] in
            self?.viewModel.input.deleteButtonTapped.send(())
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

//MARK: - Navigation Bar Items
extension DeleteAccountVC{
    private func setupNavigationBar() {
        title = "Delete Account"
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc private func cancelButtonTapped() {
        onDismiss?()
    }
}
