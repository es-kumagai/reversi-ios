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
    
    public static let leftTop: Direction = [.left, .top]
    public static let rightTop: Direction = [.right, .top]
    public static let rightBottom: Direction = [.right, .bottom]
    public static let leftBottom: Direction = [.left, .bottom]
    
    public init(rawValue: Int) {
        
        self.rawValue = rawValue
    }
}
