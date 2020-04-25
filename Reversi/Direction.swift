//
//  Direction.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

public struct Direction : OptionSet {
    
    public let rawValue: Int
    
    public static let top = Direction(rawValue: 1 << 0)
    public static let bottom = Direction(rawValue: 1 << 1)
    public static let left = Direction(rawValue: 1 << 2)
    public static let right = Direction(rawValue: 1 << 3)
    
    public static var leftTop: Direction { return [.left, .top] }
    public static var rightTop: Direction { return [.right, .top] }
    public static var rightBottom: Direction { return [.right, .bottom] }
    public static var leftBottom: Direction { return [.left, .bottom] }
    
    public static var allDirections: [Direction] {
        
        return [
            .leftTop,
            .top,
            .rightTop,
            .right,
            .rightBottom,
            .bottom,
            .leftBottom,
            .left,
        ]
    }
    
    public init(rawValue: Int) {
        
        self.rawValue = rawValue
    }
}
