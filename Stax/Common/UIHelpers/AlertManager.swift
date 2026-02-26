//
//  AlertManager.swift
//  Stax
//
//  Created by Rovshan Rasulov on 07.12.25.
//

import UIKit


final class AlertManager{
    static func showConfirmationAlert(on vc: UIViewController,
                                      title: String,
                                      message: String,
                                      confirmTitle: String,
                                      cancelTitle: String,
                                      action: @escaping () -> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: confirmTitle, style: .default) { _ in
            action()
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        DispatchQueue.main.async {
            vc.present(alert, animated: true, completion: nil)
        }
        
    }
}
