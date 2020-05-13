//
//  PlayerDelegate.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/05/12.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// プレイヤーが行動を起こしたときに通知するデリゲートです。
@objc protocol PlayerDelegate : class {
    
    /// プレイヤーが思考を始めたことを通知します。
    /// - Parameter player: 思考を始めたプレイヤーです。
    func playerThinkingWillStartByItself(_ player: Player)
    
    /// プレイヤーが思考を終えたことを通知します。
    /// - Parameters:
    ///   - player: 思考を終えたプレイヤーです。
    ///   - thought: プレイヤーが取った判断です。
    func player(_ player: Player, thinkingDidEndByItself thought: PlayerThought)
}
