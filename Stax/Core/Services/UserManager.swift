//
//  UserManager.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//

import Foundation
import Combine

final class UserManager{
    private let _currentUser = CurrentValueSubject<UserModel?, Never>(nil)
    
    var currentUserPublisher: AnyPublisher<UserModel?, Never>{
        _currentUser.eraseToAnyPublisher()
    }
    
    init(){}
    
    func updateUser(_ user: UserModel?){
        _currentUser.send(user)
    }
}
