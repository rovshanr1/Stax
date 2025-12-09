//
//  AlertManager.swift
//  Stax
//
//  Created by Rovshan Rasulov on 07.12.25.
//

import UIKit


final class AlertManager{
    private static func showTextAlert(on vc: UIViewController, with title: String, with message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showErrorAlert(on vc: UIViewController, with error: Error){
        showTextAlert(on: vc, with: "Error", with: error.localizedDescription)
    }
}
