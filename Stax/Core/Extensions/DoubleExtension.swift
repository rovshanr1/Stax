//
//  DoubleExtension.swift
//  Stax
//
//  Created by Rovshan Rasulov on 19.04.26.
//

import Foundation


extension Double{
    func formatWeight() -> String{
        let absValue = abs(self)
        
        if absValue >= 1_000_000{
            return String(format: "%.1fM", self / 1_000_000).replacingOccurrences(of: ".0", with: "")
        }else if absValue >= 1_000{
            return String(format: "%.1fk", self / 1_000).replacingOccurrences(of: ".0", with: "")
        }else{
            return "\(Int(self))"
        }
    }
}
