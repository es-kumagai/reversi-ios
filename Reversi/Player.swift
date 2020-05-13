//
//  Player.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/05/12.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// プレーヤー型を表現するプロトコルです。
///
///
@objc protocol Player : class {
    
    /// プレイヤーの種類を取得します。
    var type: PlayerType { get }
    
    /// プレイヤーが行動を起こしたことを通知するデリゲートです。
    weak var delegate: PlayerDelegate? { get }
    
    /// プレイヤーのターンが始まったときに呼び出します。
    /// - Parameters:
    ///   - side: プレイヤーの担当するディスクの色です。
    ///   - board: 現在の盤面です。
    func startThinking(withSide side: Disk, board: Board)

    /// プレイヤーのターンが終わったときに呼び出します。
    func stopThinking()
    
    /// プレイヤーが `location` の升目を選びます。
    /// - Parameter location: 目的の升目です。
    func select(location: Location)
    
    /// プレイヤーを初期化します。
    /// - Parameter delegate: デリゲートを指定します。
    init(withDelegate delegate: PlayerDelegate?)
}
