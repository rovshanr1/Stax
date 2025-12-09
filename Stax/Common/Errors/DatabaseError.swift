//
//  DatabaseError.swift
//  Stax
//
//  Created by Rovshan Rasulov on 09.12.25.
//

import Foundation

enum DatabaseError: Error {
    case unknown(String)
    
    var description: String {
        switch self {
        case .unknown(let string):
            return string
        }
    }
}
