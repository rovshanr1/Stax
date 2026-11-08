//
//  UserDefaultsKeys+Enum.swift
//  Stax
//
//  Created by Rovshan Rasulov on 14.07.26.
//

import Foundation

enum UserDefaultsKeys{
    //MARK: - App State
    static let isFirstLaunchCompleted = "isFirstLaunchCompleted"
    static let isAccountDeletionPending = "isAccountDeletionPending"
    
    // MARK: - User State (Wipe On Logout)
    static let isSeededFromFirebase = "isSeededFromFirebase"
    static let healthKitEnabled = "com.stax.healthkit.enabled"
    
    static var userStateKeysToWipe: [String] {
        return [isSeededFromFirebase, healthKitEnabled]
    }
}
