//
//  PlayerThoughtState.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/05/12.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// プレイヤーの考えを表現します。
struct PlayerThought {
    
    /// プレイヤーの考えです。
    ///
    /// 列挙型を Objective-C ブリッジすると、
    /// コンパイラーが Segmentation Fault になるので、
    /// 構造体に包んでいます。（ワークアラウンド）
    ///
    /// specified:
    ///     升目を決定したことを示します。
    /// moved:
    ///     升目にディスクを置いたことを示します。
    /// passed:
    ///     自分の手番をパスしたことを示します。
    ///
    /// aborted:
    ///     手版が中断されたことを示します。
    enum State {
        
        case specified(Location)
        case moved(Location)
        case passed
        case aborted
    }
    
    /// プレイヤーの考えです。
    var state: State
}

@objc class _PlayerThoughtStateBox : NSObject {
    
    fileprivate var thought: PlayerThought
    
    fileprivate init(_ thought: PlayerThought) {
        
        self.thought = thought
    }
}

extension PlayerThought : _ObjectiveCBridgeable {
    
    func _bridgeToObjectiveC() -> _PlayerThoughtStateBox {
        
        return _PlayerThoughtStateBox(self)
    }
    
    static func _forceBridgeFromObjectiveC(_ source: _PlayerThoughtStateBox, result: inout PlayerThought?) {
        
        result = source.thought
    }
    
    static func _conditionallyBridgeFromObjectiveC(_ source: _PlayerThoughtStateBox, result: inout PlayerThought?) -> Bool {
        
        result = source.thought
        return true
    }
    
    static func _unconditionallyBridgeFromObjectiveC(_ source: _PlayerThoughtStateBox?) -> PlayerThought {
        
        return source!.thought
    }
}
