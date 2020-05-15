//
//  PlayerControllerDelegate.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/05/12.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// プレイヤーコントローラーの変化を通知するデリゲートです。
@objc protocol PlayerControllerDelegate : class {
    
    /// プレイヤーが思考を始めた時に呼び出されます。
    /// - Parameters:
    ///   - controller: 対象のプレイヤーコントローラーです。
    ///   - side: プレイヤーの色です。
    ///   - player: 対象のプレイヤーです。
    func playerController(_ controller: PlayerController, thinkingWillStartBySide side: Disk, player: Player)
    
    /// プレイヤーが思考を終了した時に呼び出されます。
    /// - Parameters:
    ///   - controller: 対象のプレイヤーコントローラーです。
    ///   - side: プレイヤーの色です。
    ///   - player: 対象のプレイヤーです。
    ///   - thought: プレイヤーの決定した判断です。
    func playerController(_ controller: PlayerController, thinkingDidEndBySide side: Disk, player: Player, thought: PlayerThought)
}
