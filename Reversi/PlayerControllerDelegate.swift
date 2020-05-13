//
//  PlayerControllerDelegate.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/05/12.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

@objc protocol PlayerControllerDelegate : class {
    
    func playerController(_ controller: PlayerController, thinkingWillStartBySide side: Disk, player: Player)
    func playerController(_ controller: PlayerController, thinkingDidEndBySide side: Disk, player: Player, thought: PlayerThought)
}
