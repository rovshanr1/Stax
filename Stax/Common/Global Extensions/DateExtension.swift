//
//  DateExtension.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.03.26.
//

import Foundation

extension Date{
    func dayName() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
}
