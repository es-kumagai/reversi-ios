//
//  Direction.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

/// 移動方向を表現する型です。
public struct Direction : OptionSet {
    
    /// 移動方向の、プログラミング場の値表現です。
    public let rawValue: Int
    
    /// 上方向への移動を表現します。
    public static let top = Direction(rawValue: 1 << 0)
    
    /// 下方向への移動を表現します。
    public static let bottom = Direction(rawValue: 1 << 1)
    
    /// 左方向への移動を表現します。
    public static let left = Direction(rawValue: 1 << 2)
    
    /// 右方向への移動を表現します。
    public static let right = Direction(rawValue: 1 << 3)
    
    
    /// 左上方向への移動を表現します。
    public static var leftTop: Direction { return [.left, .top] }
    
    /// 右上方向への移動を表現します。
    public static var rightTop: Direction { return [.right, .top] }
    
    /// 右下方向への移動を表現します。
    public static var rightBottom: Direction { return [.right, .bottom] }
    
    /// 左下方向への移動を表現します。
    public static var leftBottom: Direction { return [.left, .bottom] }
    
    
    /// コンピューター上の値表現から、方向を生成します。
    /// - Parameter rawValue: コンピューター上の値表現です。
    public init(rawValue: Int) {
        
        self.rawValue = rawValue
    }
}
