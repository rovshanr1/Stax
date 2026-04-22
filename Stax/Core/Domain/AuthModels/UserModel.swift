//
//  UserModel.swift
//  Stax
//
//  Created by Rovshan Rasulov on 07.04.26.
//

import Foundation


nonisolated struct UserModel: Codable, Hashable, Sendable {
    let id: String
    let name: String
    let email: String
    var profileImage: String?
}
