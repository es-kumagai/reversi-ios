//
//  GameRecord.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/26.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// ゲームの勝敗状況を表現する型です。
struct GameRecord {
    
    /// ゲームの勝敗です。
    var winner: Disk?
}

@objc class _GameRecordBox : NSObject {
    
    fileprivate var record: GameRecord
 
    fileprivate init(_ record: GameRecord) {
        
        self.record = record
    }
}

extension GameRecord : _ObjectiveCBridgeable {
    
    func _bridgeToObjectiveC() -> _GameRecordBox {
        
        return _GameRecordBox(self)
    }
    
    static func _forceBridgeFromObjectiveC(_ source: _GameRecordBox, result: inout GameRecord?) {
        
        result = source.record
    }
    
    static func _conditionallyBridgeFromObjectiveC(_ source: _GameRecordBox, result: inout GameRecord?) -> Bool {
        
        result = source.record
        return true
    }
    
    static func _unconditionallyBridgeFromObjectiveC(_ source: _GameRecordBox?) -> GameRecord {
        
        return source!.record
    }
}
