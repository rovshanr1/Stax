//
//  SettingsItem+Extension.swift
//  Stax
//
//  Created by Rovshan Rasulov on 22.07.26.
//

import Foundation

nonisolated extension SettingsItem: Hashable {
    static func == (lhs: SettingsItem, rhs: SettingsItem) -> Bool {
        switch (lhs, rhs) {
        case let (.navigation(id1, icon1, title1, color1), .navigation(id2, icon2, title2, color2)):
            return id1 == id2 && icon1 == icon2 && title1 == title2 && color1 == color2
        case let (.toggle(id1, icon1, title1, isOn1, color1), .toggle(id2, icon2, title2, isOn2, color2)):
            return id1 == id2 && icon1 == icon2 && title1 == title2 && isOn1 == isOn2 && color1 == color2
        case let (.logout(id1, title1), .logout(id2, title2)):
            return id1 == id2 && title1 == title2
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }
}
