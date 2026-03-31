//
//  WelcomeVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.03.26.
//

import UIKit

enum WelcomeEventsFlow{
    case getStarted
}


class WelcomeVC: UIViewController {
    
    //Closures
    var didSendEventClosure: ((WelcomeEventsFlow) -> Void)?
    
    //ViewModel
    var vm: WelcomeVM!
    
    //Coordinator
    weak var authCoordinator: AuthCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
    }
}
