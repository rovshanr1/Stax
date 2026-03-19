//
//  HomeWorkoutPresentationItem .swift
//  Stax
//
//  Created by Rovshan Rasulov on 12.03.26.
//

import Foundation
/// Model representing workout data displayed on the Home screen (HomeVC).
///
/// - Important: **Why are Equatable and Hashable implemented manually?**
/// In Swift 6, automatically synthesized conformances may become `@MainActor`-isolated.
/// However, `UITableViewDiffableDataSource` performs diffing on a background thread.
///
/// To avoid the "Main actor-isolated conformance cannot be used in a nonisolated context"
/// error, these conformances are implemented manually and marked as `nonisolated`.
nonisolated struct HomeWorkoutPresentationItem: Sendable{
    let id: String
    let title: String
    let dateString: String
    let time: String
    let volume: String
}

nonisolated extension HomeWorkoutPresentationItem: Equatable {
    static func == (lhs: HomeWorkoutPresentationItem, rhs: HomeWorkoutPresentationItem) -> Bool {
        return lhs.id == rhs.id
        && lhs.title == rhs.title
        && lhs.dateString == rhs.dateString
        && lhs.time == rhs.time
        && lhs.volume == rhs.volume
    }
}

nonisolated extension HomeWorkoutPresentationItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(dateString)
        hasher.combine(time)
        hasher.combine(volume)
    }
}
