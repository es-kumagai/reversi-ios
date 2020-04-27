//
//  Square.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

struct Square {
    
    var location: Location
    var state: State = .empty
}

@objc class _SquareBox : NSObject {
    
    fileprivate var square: Square
    
    fileprivate init(_ square: Square) {
        
        self.square = square
    }
}

extension Square : _ObjectiveCBridgeable {
    
    func _bridgeToObjectiveC() -> _SquareBox {
        
        return _SquareBox(self)
    }
    
    static func _forceBridgeFromObjectiveC(_ source: _SquareBox, result: inout Square?) {
        
        result = source.square
    }
    
    static func _conditionallyBridgeFromObjectiveC(_ source: _SquareBox, result: inout Square?) -> Bool {
        
        result = source.square
        return true
    }
    
    static func _unconditionallyBridgeFromObjectiveC(_ source: _SquareBox?) -> Square {
        
        return source!.square
    }
}
