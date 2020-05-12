//
//  PlayerDelegate.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/05/12.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

@objc protocol PlayerDelegate : class {
    
    func playerThinkingWillStartByItself(_ player: Player)
    func player(_ player: Player, thinkingDidEndByItself thought: PlayerThought)
}
