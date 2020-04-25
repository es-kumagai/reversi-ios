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

        switch direction {
            
        case .top:
            return Location(col: col, row: row - 1)

        case .bottom:
            return Location(col: col, row: row + 1)

        case .left:
            return Location(col: col - 1, row: row)

        case .right:
            return Location(col: col + 1, row: row)
        }
    }
}
