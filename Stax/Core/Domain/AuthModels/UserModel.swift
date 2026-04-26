//
//  UserModel.swift
//  Stax
//
//  Created by Rovshan Rasulov on 07.04.26.
//

import Foundation


nonisolated struct UserModel: Codable, Hashable, Sendable {
    let id: String
    var name: String
    var email: String
    var profileImage: String?
    var bio: String?
}
