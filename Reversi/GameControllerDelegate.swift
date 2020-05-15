//
//  GameControllerDelegate.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// ゲームコントローラの状態変化を通知します。
@objc protocol GameControllerDelegate : class {
    
    /// プレイヤーが思考を開始した時に呼び出されます。
    /// - Parameters:
    ///   - controller: 対象のゲームコントローラーです。
    ///   - side: 思考を始めたプレイヤーの色です。
    ///   - player: 対象のプレイヤーです。
    func gameController(_ controller: GameController, thinkingWillStartBySide side: Disk, player: Player)
    
    /// プレイヤーが思考を終えた時に呼び出されます。
    /// - Parameters:
    ///   - controller: 対象のゲームコントローラーです。
    ///   - side: 思考を終えたプレイヤーの色です。
    ///   - player: 対象のプレイヤーです。
    func gameController(_ controller: GameController, thinkingDidEndBySide side: Disk, player: Player)
    
    /// ターンが変わった時に呼び出されます。
    /// - Parameters:
    ///   - controller: 対象のゲームコントローラーです。
    ///   - side: 変わった後のターンの色です。
    func gameController(_ controller: GameController, turnChanged side: Disk)
    
    /// ディスクを打つ場所がなかった時に通知します。
    /// - Parameters:
    ///   - controller: 対象のゲームコントローラーです。
    ///   - side: 対象のターンの色です。
    func gameController(_ controller: GameController, cannotMoveAnyware side: Disk)
    
    /// ゲームが終了した時に呼び出されます。
    /// - Parameters:
    ///   - controller: 対象のゲームコントローラーです。
    ///   - record: ゲームの勝敗です。
    ///   - board: ゲーム終了次のボードです。
    func gameController(_ controller: GameController, gameOverWithWinner record: GameRecord, board: Board)
    
    /// ゲームが開始された時に呼び出されます。
    /// - Parameters:
    ///   - controller: 対象のゲームコントローラーです。
    ///   - board: ゲーム開始時のボードです。
    ///   - turn: どの色の手番かを示します。
    ///   - players: 手番のプレイヤーです。
    func gameController(_ controller: GameController, gameDidStartWithBoard board: Board, turn: Disk, players: Players)
    
    /// 升目のディスクが変化した時に呼び出されます。
    /// - Parameters:
    ///   - controller: 対象のゲームコントローラーです。
    ///   - state: マス目の変化後の状態です。
    ///   - location: 変化した升目の位置です。
    ///   - duration: 升目の置き換えに必要な所要時間です。
    func gameController(_ controller: GameController, setSquare state: Square.State, location: Location, animationDuration duration: Double)
    
    /// ボードの状態が変化した時に呼び出されます。
    /// - Parameters:
    ///   - controller: 対象のゲームコントローラーです。
    ///   - board: 変更後のボードです。
    ///   - moves: ボードの状態が変化した升目です。
    ///   - duration: 升目の置き換えに必要な所要時間です。
    func gameController(_ controller: GameController, boardChanged board: Board, moves: [Location], animationDuration duration: Double)
}
