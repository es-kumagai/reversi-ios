//
//  Location.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

struct Location {
    
    var col: Int
    var row: Int
}

extension Location {
    
    func next(to direction: Direction) -> Location {

        var location = self
        
        if direction.contains(.top) {

            location = Location(col: location.col, row: location.row - 1)
        }

        if direction.contains(.bottom) {

            location = Location(col: location.col, row: location.row + 1)
        }

        if direction.contains(.left) {

            location = Location(col: location.col - 1, row: location.row)
        }

        if direction.contains(.right) {

            location = Location(col: location.col + 1, row: location.row)
        }
        
        return location
    }
}

@objc class _LocationBox : NSObject {
    
    fileprivate var location: Location
    
    fileprivate init(_ location: Location) {

        self.location = location
    }
}

extension Location : _ObjectiveCBridgeable {
    
    func _bridgeToObjectiveC() -> _LocationBox {
        
        return _LocationBox(self)
    }
    
    static func _forceBridgeFromObjectiveC(_ source: _LocationBox, result: inout Location?) {
        
        result = source.location
    }
    
    static func _conditionallyBridgeFromObjectiveC(_ source: _LocationBox, result: inout Location?) -> Bool {
        
        result = source.location
        return true
    }
    
    static func _unconditionallyBridgeFromObjectiveC(_ source: _LocationBox?) -> Location {
        
        return source!.location
    }
}
