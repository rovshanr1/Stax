//
//  UserDataWipeService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 03.06.26.
//

import Foundation


protocol UserDataWipeServiceProtocol{
    func wipeAllLocalData() async throws
}

final class UserDataWipeService: UserDataWipeServiceProtocol {
    private let userDefaults: UserDefaults
    private let persistenceController: PersistenceController
    
    init(userDefaults: UserDefaults,
         persistenceController: PersistenceController,
    ) {
        self.userDefaults = userDefaults
        self.persistenceController = persistenceController
    }
    
    
    func wipeAllLocalData() async throws {
        self.wipeUserDefaults()
        try self.persistenceController.resetStack()
    }
    
    
    
    private func wipeUserDefaults() {
        guard let domain = Bundle.main.bundleIdentifier else { return }
        
        userDefaults.removePersistentDomain(forName: domain)
    }
    
}
