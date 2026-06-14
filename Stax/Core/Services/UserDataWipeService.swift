//
//  UserDataWipeService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 03.06.26.
//

import Foundation


protocol UserDataWipeServiceProtocol{
    func setDeletionPending(_ pending: Bool)
    func isDeletionPending() -> Bool
    func wipeAllLocalData() async throws
}

final class UserDataWipeService: UserDataWipeServiceProtocol {
  
    
    private let userDefaults: UserDefaults
    private let persistenceController: PersistenceControllerProtocol
    
    private let deletionPendingKey = "isAccountDeletionPending"
    
    init(userDefaults: UserDefaults = .standard,
         persistenceController: PersistenceControllerProtocol = PersistenceController(),
    ) {
        self.userDefaults = userDefaults
        self.persistenceController = persistenceController
    }
    
    
    func setDeletionPending(_ pending: Bool) {
        userDefaults.set(pending, forKey: deletionPendingKey)
    }
    
    func isDeletionPending() -> Bool {
        return userDefaults.bool(forKey: deletionPendingKey)
    }
    
    func wipeAllLocalData() async throws {
        self.wipeUserDefaults()
        try self.persistenceController.resetStack()
        
        setDeletionPending(false)
    }
    
    
    
    private func wipeUserDefaults() {
        guard let domain = Bundle.main.bundleIdentifier else { return }
        
        userDefaults.removePersistentDomain(forName: domain)
    }
    
}
