//
//  AppPreferencesService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.02.26.
//

import Foundation

protocol AppPreferencesServiceInterface{
    var isHealthKitSyncEnabled: Bool {get set}
}

class AppPreferencesService: AppPreferencesServiceInterface{
    
    private let defaults: UserDefaults
    private let healthKitKey = UserDefaultsKeys.healthKitEnabled
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    var isHealthKitSyncEnabled: Bool {
        get{
            return defaults.bool(forKey: healthKitKey)
        }
        set{
            defaults.set(newValue, forKey: healthKitKey)
        }
    }
}
