//
//  WorkoutSessionRowItem+Extension.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.08.26.
//

import Foundation

nonisolated extension WorkoutSessionRowItems: Hashable{
    static func == (lhs: WorkoutSessionRowItems, rhs: WorkoutSessionRowItems) -> Bool{
        switch(lhs, rhs){
        case (.duration, .duration): return true
        case (.empty, .empty): return true
        case let (.exercise(l), .exercise(r)): return l.id == r.id
        default : return false
        }
    }
    
    func hash(into hasher: inout Hasher){
        switch self{
        case .duration: hasher.combine("duration")
        case .empty: hasher.combine("empty")
        case .exercise(let model): hasher.combine(model.id) 
        }
    }
}
