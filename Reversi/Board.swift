//
//  Board.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// ゲームで使う盤面です。
struct Board {
    
    /// 盤面の列数です。
    let cols: Int
    
    /// 盤面の行数です。
    let rows: Int
    
    
    /// 盤面の状態を配列で表現します。
    private(set) var squares: [Square]
    
    /// 盤面を初期化します。
    /// - Parameters:
    ///   - cols: 盤面の列数です。
    ///   - rows: 盤面の行数です。
    init(cols: Int, rows: Int) {
        
        self.cols = cols
        self.rows = rows
        
        squares = []
        
        for row in 0 ..< rows {
            
            for col in 0 ..< cols {
                
                squares.append(Square(location: Location(col: col, row: row)))
            }
        }
    }
}

private extension Board {
    
    /// 位置情報から、配列表現での升目のインデックスを取得します。
    /// - Parameter location: 位置情報を指定します。
    /// - Returns: 位置情報が該当する配列のインデックスを返します。
    func squareIndex(of location: Location) -> Int {
        
        return location.row * rows + location.col
    }
}

extension Board {
    
    /// 盤上の升目の数です。
    var squareCount: Int {
        
        return cols * rows
    }
    
    /// `side` で指定された色のディスクが盤上に置かれている枚数を返します。
    /// - Parameter side: 数えるディスクの色です。
    /// - Returns: `side` で指定された色のディスクの、盤上の枚数です。
    func count(of side: Disk) -> Int {
        
        return squares
            .filter { $0.state.side == side }
            .count
    }

    /// 盤上の全ての升目を列単位で取得します。
    var squaresPerRow: [[Square]] {
        
        var result: [[Square]] = []
        
        for row in 0 ..< rows {
            
            let squaresAtRow = squares.filter { $0.location.row == row }
            
            result.append(squaresAtRow)
        }
        
        return result
    }
    
    /// `location` で指定された升目に `disk` を設定します。
    /// - Parameter location: セルの位置です。
    subscript(_ location: Location) -> Square.State {
        
        get {
            
            return squares[squareIndex(of: location)].state
        }
        
        set (state) {

            squares[squareIndex(of: location)].state = state
        }
    }
    
    /// 盤をゲーム開始時に状態に戻します。
    mutating func reset() {
        
        for square in squares {
            
            self[square.location] = .empty
        }
        
        self[Location(col: cols / 2 - 1, row: rows / 2 - 1)] = .light
        self[Location(col: cols / 2, row: rows / 2 - 1)] = .dark
        self[Location(col: cols / 2 - 1, row: rows / 2)] = .dark
        self[Location(col: cols / 2, row: rows / 2)] = .light
    }
    
    /// `location` が盤上に収まるかを調べます。
    /// - Parameter location: 盤の位置
    /// - Returns: おさまる場合に `true` そうでない場合は `false`
    func contains(_ location: Location) -> Bool {
        
        return contains(col: location.col) && contains(row: location.row)
    }
    
    /// `col` が盤面の列内に収まるかを調べます。
    /// - Parameter col: 盤の列位置
    /// - Returns: おさまる場合に `true` そうでない場合は `false`
    func contains(col: Int) -> Bool {
        
        return (0 ..< cols).contains(col)
    }
    
    /// `row`
    /// - Parameter row: 盤の行位置
    /// - Returns: おさまる場合に `true` そうでない場合は `false`
    func contains(row: Int) -> Bool {
        
        return (0 ..< rows).contains(row)
    }

    /// `side` で指定された色のディスクを置ける盤上のセルの座標をすべて返します。
    /// - Returns: `side` で指定された色のディスクを置ける盤上のすべてのセルの座標の配列です。
    func validMoves(for side: Disk) -> [Location] {
        var locations: [Location] = []
        
        for square in squares {
            if canPlaceDisk(side, at: square.location) {
                locations.append(square.location)
            }
        }
        
        return locations
    }
    
    /// `side` で指定した側が次の一手を持っているか調べます。
    /// - Parameter side: 対象となる色です。
    /// - Returns: 次の一手を打てる場合に `true` を、そうでなければ `false` を返します。
    func nextMoveAvailable(on side: Disk) -> Bool {
        
        return !validMoves(for: side).isEmpty
    }

    /// `location` で指定されたセルに、 `disk` が置けるかを調べます。
    /// ディスクを置くためには、少なくとも 1 枚のディスクをひっくり返せる必要があります。
    /// - Parameter location: セルの位置です。
    /// - Returns: 指定されたセルに `disk` を置ける場合は `true` を、置けない場合は `false` を返します。
    func canPlaceDisk(_ disk: Disk, at location: Location) -> Bool {
        !flipLocationsBy(disk, at: location).isEmpty
    }
    
    /// 移動可能な全方向を取得します。角は考慮しません。
    var allDirections: [Direction] {
        
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
    
    /// 裏返せるディスクの位置を取得します。
    /// - Parameters:
    ///   - disk: 裏返すのに使うディスクの面です。
    ///   - location: ディスクを置く場所です。
    /// - Returns: ディスクを置いたことによって裏返されるディスクを返します。
    func flipLocationsBy(_ disk: Disk, at location: Location) -> [Location] {
        
        guard self[location] == .empty else {
            return []
        }
        
        var diskLocations: [Location] = []
        
        for direction in allDirections {
            
            var location = location
            var diskLocationsInLine: [Location] = []
            
            flipping: while true {
                
                location = location.next(to: direction)
                
                guard contains(location) else {
                    
                    break flipping
                }
                
                switch (disk, self[location]) { // Uses tuples to make patterns exhaustive
                case (.dark, .dark), (.light, .light):
                    diskLocations.append(contentsOf: diskLocationsInLine)
                    break flipping
                case (.dark, .light), (.light, .dark):
                    diskLocationsInLine.append(location)
                case (_, .empty):
                    break flipping
                }
            }
        }
        
        return diskLocations
    }
}

@objc class _BoardBox : NSObject {
    
    fileprivate var board: Board
    
    fileprivate init(_ board: Board) {

        self.board = board
    }
}

extension Board : _ObjectiveCBridgeable {
    
    func _bridgeToObjectiveC() -> _BoardBox {
        
        return _BoardBox(self)
    }
    
    static func _forceBridgeFromObjectiveC(_ source: _BoardBox, result: inout Board?) {
        
        result = source.board
    }
    
    static func _conditionallyBridgeFromObjectiveC(_ source: _BoardBox, result: inout Board?) -> Bool {
        
        result = source.board
        return true
    }
    
    static func _unconditionallyBridgeFromObjectiveC(_ source: _BoardBox?) -> Board {
        
        return source!.board
    }
}
