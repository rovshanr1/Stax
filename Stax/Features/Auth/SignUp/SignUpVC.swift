//
//  SignUpVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.04.26.
//

import UIKit

class SignUpVC: UIViewController {
    
    var vm: SignUpVM!
    weak var coordinator: AuthCoordinatorProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
