//
//  FinishSound.swift
//  Stax
//
//  Created by Rovshan Rasulov on 06.10.26.
//

import AudioToolbox
import UIKit

final class FinishSound{
    static func playRestFinishedFeedback(){
        AudioServicesPlaySystemSound(1007)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
