//
//  Location.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

public struct Location {
    
    public var col: Int
    public var row: Int
}

extension Location {
    
    public func next(to direction: Direction) -> Location {

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
