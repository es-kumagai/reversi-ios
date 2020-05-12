//
//  PlayerControllerDelegate.swift
//  Reversi
//
//  Created by kumagai on 2020/05/11.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

@objc protocol PlayerControllerDelegate : class {
    
    func playerController(_ controller: PlayerController, didMoveAt location: Location, side: Disk)
    func playerController(_ controller: PlayerController, didPassedBy side: Disk)
}
