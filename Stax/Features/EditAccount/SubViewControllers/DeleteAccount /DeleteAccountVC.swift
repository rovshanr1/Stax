//
//  DeleteAccountVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 03.06.26.
//

import UIKit

class DeleteAccountVC: UIViewController {
    
    private let viewModel: DeleteAccountVM
    
    init(viewModel: DeleteAccountVM) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
    }
    

   

}
