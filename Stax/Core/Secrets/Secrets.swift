//
//  Secrets.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.04.26.
//

import Foundation

enum Secrets{
    static var imageKitPublicKey: String{
        Bundle.main.infoDictionary?["IMAGEKIT_PUBLIC_KEY"] as? String ?? ""
    }
}
