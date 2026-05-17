//
//  EditAccountVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 16.05.26.
//

import UIKit
import Combine

class EditAccountVC: UIViewController {
    
    private var viewModel: EditAccountVM
    var didSentEventClosure: ((EditAccountEvent) -> Void)?
    
    private let contentView = EditAccountView()
    
    init(viewModel: EditAccountVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Eddit Account"
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    
    deinit{
     print("EditAccount deinited")
    }
  
    
    //MARK: - Bind ViewModel

}
