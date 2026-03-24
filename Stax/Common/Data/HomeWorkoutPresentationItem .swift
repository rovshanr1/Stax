//
//  HomeWorkoutPresentationItem .swift
//  Stax
//
//  Created by Rovshan Rasulov on 12.03.26.
//

import Foundation

nonisolated struct ExerciseSummaryItem: Hashable, Sendable{
    let exerciseName: String
    let imageURl: String?
}

nonisolated struct HomeWorkoutPresentationItem: Hashable, Sendable{
    let id: String
    let title: String
    let dateString: String
    let time: String
    let volume: String
    let exerciseSummar: [ExerciseSummaryItem]
    let moreText: String?
}

