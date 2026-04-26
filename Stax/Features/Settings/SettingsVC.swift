//
//  SettingsVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//

import UIKit
import Combine

class SettingsVC: UIViewController {
    
    //closures
    var didSentEventClosure: ((SettingsEvent) -> Void)?
    
    //private properties
    private var contentView = SettingsView()
    private let vm: SettingsVM
    private var cancellables: Set<AnyCancellable> = []
    
    init(vm: SettingsVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        bindingActions()
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
        print("Setting Deinited")
    }
    
    private func bindViewModel() {
        vm.output.logoutCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                
                self?.didSentEventClosure?(.logout)
            }
            .store(in: &cancellables)
        
    }
    
    private func bindingActions() {
        contentView.logoutTapped = { [weak self] in
            self?.vm.input.logoutTapped.send()
        }
    }
    
}
