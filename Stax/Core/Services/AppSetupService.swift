//
//  AppSetupService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.04.26.
//

import Foundation
import Kingfisher
import FirebaseCore
import ImageKitIO

final class AppSetupService{
    static let shared = AppSetupService()
    private init() {}
    
    func setupAllServices() {
        configureFirebase()
        configureKingfisher()
        configureImageKitIO()
    }
    
   private func configureKingfisher(){
        let cache = ImageCache.default
        cache.diskStorage.config.sizeLimit = 200 * 1024 * 1024
        cache.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024
        cache.diskStorage.config.expiration = .days(7)
    }
    
    private func configureFirebase(){
        FirebaseApp.configure()
    }
    
    private func configureImageKitIO(){
       _ =  ImageKit.init(
            publicKey: Secrets.imageKitPublicKey,
            urlEndpoint: "https://ik.imagekit.io/wgp06waey"
        )
    }
}
