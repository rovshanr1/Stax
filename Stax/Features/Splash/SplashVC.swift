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
    
    private var isAnimationFinished = false
    private var isSyncCompleted = false
    private var hasProceeded = false
    private var hasStartedAnimation = false
    
    init(vm: SplashVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Ekran pəncərədə olandan sonra başlayır; modal bağlananda təkrar başlamasın
        guard !hasStartedAnimation else { return }
        hasStartedAnimation = true
        
        contentView.startAnimation { [weak self] in
            self?.isAnimationFinished = true
            self?.proceedIfReady()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.stopAnimation()
    }
    
    private func bindViewModel() {
        vm.output.syncCompleted
            .filter { $0 }
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isSyncCompleted = true
                self?.proceedIfReady()
            }
            .store(in: &cancellables)
    }
    
    private func proceedIfReady() {
        guard isAnimationFinished, isSyncCompleted, !hasProceeded else { return }
        hasProceeded = true
        didSentEventClosure?(.syncComplated)
    }
}
