//
//  SplashVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.04.26.
//

import UIKit
import Combine

enum SplashEvent{
    case syncComplated
}

class SplashVC: UIViewController {
    var didSentEventClosure: ((SplashEvent) -> Void)?

    var vm: SplashVM
    
    let contentView = SplashView()
    
    var cancellables: Set<AnyCancellable> = []
    
    init(vm: SplashVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.loadingIndicator.startAnimating()
        
        bindViewModel()

    }
    
    override func loadView() {
        self.view = contentView
    }
    
    private func bindViewModel() {
        vm.output.syncCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.didSentEventClosure?(.syncComplated)
            }
            .store(in: &cancellables)
    }

}
