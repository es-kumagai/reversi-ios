//
//  ViewUpdateControllerDelegate.swift
//  Reversi
//
//  Created by kumagai on 2020/04/27.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// ビューの更新制御による通知です。
@objc protocol ViewUpdateControllerDelegate : class {
    
    /// 升目の更新を通知します。
    /// - Parameters:
    ///   - controller: 送信元のコントローラーです。
    ///   - state: 更新後の升目の状態です。
    ///   - location: 対象の升目の位置です。
    ///   - animated: アニメーションを行う場合は `true` そうでなければ `false` です。
    func viewUpdateController(_ controller: ViewUpdateController, updateSquare state: Square.State, location: Location, animated: Bool)
    
    /// ボードの更新を通知します。
    /// - Parameters:
    ///   - controller: 送信元のコントローラーです。
    ///   - board: 更新後のボードです。
    ///   - animated: アニメーションを行う場合は `true` そうでなければ `false` です。
    func viewUpdateController(_ controller: ViewUpdateController, updateBoard board: Board, animated: Bool)
}
