//
//  TurnController.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/26.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// ゲームのターン状態を管理するコントローラーです。
class TurnController : NSObject {
    
    /// 試合中でどちらの色のプレイヤーのターンかを `.playing` で表します。ゲーム終了時は `.over` です。
    private(set) var currentState: TurnState = .over
    
    /// どのような理由で今のターンになったかを示します。
    private(set) var turnChangedReason: ChangedReason = .initial
    
    /// ゲームが終了した状態にあるかを取得します。
    var isGameOver: Bool {
        
        switch currentState {
            
        case .over:
            return true
            
        case .playing:
            return false
        }
    }
    
    /// どちらの色のプレイヤーのターンかを表します。ゲーム終了時は `nil` です。
    var currentTurn: Disk? {
        
        switch currentState {
            
        case .playing(side: let side):
            return side
            
        case .over:
            return nil
        }
    }
    
    /// ターンの状態を、ゲーム終了の状態にリセットします。
    func turnReset() {
    
        currentState = .over
        turnChangedReason = .initial
    }
    
    /// ターンの状態を、指定した手番でリセットします。
    /// - Parameter side: ゲームの手番です。
    func turnReset(with side: Disk) {
    
        currentState = .playing(side: side)
        turnChangedReason = .initial
    }
    
    /// ターンの状態を変更します。
    /// - Parameters:
    ///   - side: 変更後の手番です。
    ///   - reason: 手番の変更理由です。
    func turnChange(to side: Disk, reason: ChangedReason) {
        
        if turnChangedReason == .passed && reason == .passed {
            
            currentState = .over
            turnChangedReason = .passed
        }
        else {
            
            currentState = .playing(side: side)
            turnChangedReason = reason
        }
    }
}

extension TurnController {
    
    /// ターンの変更理由です。
    ///
    /// initial
    ///     ゲームの開始または再開のため。
    /// moved
    ///     前のプレイヤーが手を打ったため。
    /// passed s
    ///     前のプレイヤーがパスしたため。
    enum ChangedReason {
        
        case initial
        case moved
        case passed
    }
}
