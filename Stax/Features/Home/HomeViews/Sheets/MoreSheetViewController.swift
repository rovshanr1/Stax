//
//  MoreSheetViewController.swift
//  Stax
//
//  Created by Rovshan Rasulov on 12.03.26.
//

import UIKit
import SnapKit

class MoreSheetViewController: UIViewController {
    //Closures
    var sendEventClosure: ((HomeEvent) -> Void)?
    
    //ContentView
    private let contentView = MoreSheetView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    private func setupUI(){
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func handleEvent(){
        
    }
}
