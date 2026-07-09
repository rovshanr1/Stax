//
//  DeleteAccountVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 03.06.26.
//

import UIKit

class DeleteAccountVC: UIViewController {
    var onDismiss: (() -> Void)?
    
    private let viewModel: DeleteAccountVM
    private let contentView = DeleteAccountView()
    
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
        
    }
    
    
    override func loadView() {
        self.view = contentView
    }

    deinit{
        print("dismissed delete account view")
    }
    
    //MARK: - Bind ViewModel
    private func bindViewModel() {
        
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
