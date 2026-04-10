//
//  KeyboardManager.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.04.26.
//

import UIKit

final class KeyboardManager{

    private weak var scrollView: UIScrollView?
    private let extraBuffer: CGFloat
    
    init(scrollView: UIScrollView? = nil, extraBuffer: CGFloat = 50) {
        self.scrollView = scrollView
        self.extraBuffer = extraBuffer
        setupObserver()
    }
    
    private func setupObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc private func keyboardWillShow(_ notification: Notification){
        guard let scrollView = scrollView,
              let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let bottomPadding = keyboardFrame.height + extraBuffer
        
        var contentInset = scrollView.contentInset
        contentInset.bottom = bottomPadding
        
        var scrollIndicatorInset = scrollView.verticalScrollIndicatorInsets
        scrollIndicatorInset.bottom = bottomPadding
        
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        UIView.animate(withDuration: duration) {
            scrollView.contentInset = contentInset
            scrollView.verticalScrollIndicatorInsets = scrollIndicatorInset
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification){
        guard let scrollView = scrollView else { return }
        
        let duration = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double ?? 0.3
        
        UIView.animate(withDuration: duration, animations: {
            scrollView.contentInset = .zero
            scrollView.verticalScrollIndicatorInsets = .zero
        })
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }

}
