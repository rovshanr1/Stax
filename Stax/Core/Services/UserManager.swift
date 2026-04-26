//
//  UserManager.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//

import Foundation
import Combine

final class UserManager{
    let currentUser = CurrentValueSubject<UserModel?, Never>(nil)
    
    init(){}
    
    func updateUser(user: UserModel?){
        currentUser.send(user)
    }
}
