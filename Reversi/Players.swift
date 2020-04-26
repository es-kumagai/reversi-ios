//
//  Players.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

struct Players {
    
    var darkSide: Player
    var lightSide: Player
}

extension Players {
    
    subscript(of side: Disk) -> Player {
        
        get {
            
            switch side {
                
            case .dark:
                return darkSide
                
            case .light:
                return lightSide
            }
        }
        
        set (player) {
            
            switch side {
                
            case .dark:
                darkSide = player
                
            case .light:
                lightSide = player
            }
        }
    }
}

@objc class _PlayersBox : NSObject {
    
    fileprivate var players: Players
    
    fileprivate init(_ players: Players) {
        
        self.players = players
    }
}

extension Players : _ObjectiveCBridgeable {
    
    func _bridgeToObjectiveC() -> _PlayersBox {
        
        return _PlayersBox(self)
    }
    
    static func _forceBridgeFromObjectiveC(_ source: _PlayersBox, result: inout Players?) {
        
        result = source.players
    }
    
    static func _conditionallyBridgeFromObjectiveC(_ source: _PlayersBox, result: inout Players?) -> Bool {
        
        result = source.players
        return true
    }
    
    static func _unconditionallyBridgeFromObjectiveC(_ source: _PlayersBox?) -> Players {
        
        return source!.players
    }
}
