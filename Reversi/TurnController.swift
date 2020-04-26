//
//  TurnController.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/26.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

class TurnController : NSObject {
    
    /// 試合中でどちらの色のプレイヤーのターンかを `.playing` で表します。ゲーム終了時は `.over` です。
    private(set) var currentState: GameState = .over

    private(set) var turnChangedReason: ChangedReason = .resume

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
    
    func turnReset() {
    
        currentState = .over
        turnChangedReason = .resume
    }
    
    func turnReset(with side: Disk) {
    
        currentState = .playing(side: side)
        turnChangedReason = .resume
    }
    
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
    
    enum ChangedReason {
        
        case resume
        case moved
        case passed
    }
}
