//
//  Serializer.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/27.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

/// 直列化を行う関数ビルダーです。
@_functionBuilder
enum Serialization {
    
    /// インスタンスを直列化します。
    /// - Parameters:
    ///   - turn: 対象のターン情報です。
    ///   - players: 対象のプレイヤー情報です。
    ///   - board: 対象の盤面情報です。
    /// - Returns: 直列化された文字列を返します。
    static func buildBlock(_ turn: TurnState, _ players: Players, _ board: Board) -> String {
        
        return Serializer.serialization(turn: turn, players: players, board: board)
    }
}

/// 文字列を連結する関数ビルダーです。
@_functionBuilder
private enum MultilineString {
    
    static func buildBlock(_ strings: String ...) -> String {
        
        return strings.joined(separator: "\n") + "\n"
    }
}

/// 直列化を担う型です。
enum Serializer {
    
    /// 直列化を実施します。
    /// - Parameters:
    ///   - turn: 対象のターン情報です。
    ///   - players: 対象のプレイヤー動作モードです。
    ///   - board: 対象の盤面です。
    /// - Returns: 直列化された文字列を返します。
    @MultilineString
    static func serialization(turn: TurnState, players: Players, board: Board) -> String {
        
        serialization(turn: turn) + serialization(players: players)
        serialization(board: board)
    }
}

private extension Serializer {
    
    /// ターン情報を直列化します。
    /// - Parameter turn: 対象のターン情報です。
    /// - Returns: 直列化された文字列です。
    static func serialization(turn: TurnState) -> String {
        
        return turn.description
    }
    
    /// プレイヤーの動作モード情報を直列化します。
    /// - Parameter turn: 対象の動作モード情報です。
    /// - Returns: 直列化された文字列です。
    static func serialization(players: Players) -> String {
        
        return Disk.sides.reduce("") { result, side in
            
            return result + players[of: side].type.rawValue.description
        }
    }
    
    /// 升目情報を直列化します。
    /// - Parameter turn: 升目のターン情報です。
    /// - Returns: 直列化された文字列です。
    static func serialization(square: Square) -> String {
        
        return square.state.description
    }

    /// 盤面情報を直列化します。
    /// - Parameter turn: 盤面のターン情報です。
    /// - Returns: 直列化された文字列です。
    static func serialization(board: Board) -> String {
        
        return board.squaresPerRow.map { squares in
            
            squares.reduce("") { serializedRow, square in
                
                serializedRow + serialization(square: square)
            }
        }
        .joined(separator: "\n")
    }
}
