//
//  HomeVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit

enum HomeEvent{
    case homeButtonTapped
}

class HomeVC: UIViewController {
    var didSendEventClosure: ((HomeEvent) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
