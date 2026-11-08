//
//  UIWindow+Extension.swift
//  Stax
//
//  Created by Rovshan Rasulov on 13.07.26.
//

import UIKit

extension UIWindow{
    func switchRootViewController(to viewController: UIViewController,
                                  animated: Bool = true, duration: TimeInterval = 0.3,
                                  options: UIView.AnimationOptions = .transitionCrossDissolve,
                                  completion: (() -> Void)? = nil){
        
        guard animated else{
            self.rootViewController = viewController
            self.makeKeyAndVisible()
            completion?()
            return
        }
        
        guard let snapshot = self.snapshotView(afterScreenUpdates: true) else {
            self.rootViewController = viewController
            self.makeKeyAndVisible()
            completion?()
            return
        }
        
        viewController.view.addSubview(snapshot)
        
        self.rootViewController = viewController
        self.makeKeyAndVisible()
        
        UIView.animate(withDuration: duration, animations: {
            snapshot.alpha = 0.0
            snapshot.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//            if #available(iOS 13.0, *) {
//                self.overrideUserInterfaceStyle = .unspecified
//            }
        }) { _ in
            snapshot.removeFromSuperview()
            completion?()
        }
    }
}
