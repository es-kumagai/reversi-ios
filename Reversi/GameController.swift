//
//  GameController.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

class GameController : NSObject {
    
    private(set) var board = Board(cols: 8, rows: 8)
    
    /// 現在のターンでディスクを置いて良い状態であることを示します。アニメーションが終わる頃合いを待つのに使います。
    private(set) var allowPlacingOnThisTurn = true
    
    /// アニメーションの待ち時間を指定します。
    private var animationDuration = 0.3
    @IBOutlet weak var delegate: GameControllerDelegate?
    
    @IBOutlet private var playerController: PlayerController!
    @IBOutlet private var turnController: TurnController!
    @IBOutlet private var fileController: FileController!
    
    private var playerCancellers: [Disk: Canceller] = [:]
    
    func newGame() {
        
        for side in Disk.sides {
            
            playerCancellers[side]?.cancel()
            playerCancellers.removeValue(forKey: side)
            playerController.changePlayer(of: side, to: .manual)
        }
        
        turnController.turnReset(with: .dark)
        allowPlacingOnThisTurn = true
        
        board.reset()
        
        delegate?.gameController(self, gameDidStartWithBoard: board, turn: .dark, players: playerController.players)
    }
    
    /// プレイヤーの行動を待ちます。
    func waitForPlayer(afterDelay delay: Double) {
        
        guard let turn = turnController.currentTurn else {
            
            return
        }
        
        guard nextMoveAvailable(on: turn) else {
                        
            if nextMoveAvailable(on: turn.flipped) {

                delegate?.gameController(self, cannotMoveAnyware: turn)
            }
            else {
                
                nextTurn(withReason: .passed)
                waitForPlayer(afterDelay: 0)
            }
            
            return
        }
        
        switch player(of: turn) {
            
        case .manual:
            break
            
        case .computer:
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                
                self.playTurnOfComputer()
            }
        }
    }
    
    func changePlayer(_ player: Player, of side: Disk) {
        
        if let canceller = playerCancellers[side] {
            canceller.cancel()
        }
        
        playerController.changePlayer(of: side, to: player)
        try? saveGame()
        
        if side == turnController.currentTurn, case .computer = player {
            playTurnOfComputer()
        }
    }
    
    /// `location` で指定された升目の `disk` を参照します。
    /// - Parameter disk: 升目のディスクです。 `nil` はディスクが置かれていない状態を表します。
    /// - Parameter location: セルの位置です。
    func disk(at location: Location) -> Disk? {
        
        guard board.contains(location) else {
            
            fatalError("Location Out of Range: \(location)")
        }
        
        return board[location].side
    }
    
    /// `location` で指定された升目に `disk` を設定します。
    /// - Parameter state: 升目に設定される新しい状態です。
    /// - Parameter location: セルの位置です。
    /// - Parameter animationDuration: アニメーション表示時の待ち時間です。
    func set(_ state: Square.State, at location: Location, animationDuration duration: Double) {
        
        guard board.contains(location) else {
            
            fatalError("Location Out of Range: \(location)")
        }
        
        guard board[location] != state else {
            
            return
        }
        
        board[location] = state
        
        delegate?.gameController(self, setSquare: state, location: location, animationDuration: duration)
    }
    
    /// 盤上に置かれたディスクの枚数が多い方の色を返します。
    /// 引き分けの場合は `nil` が返されます。
    /// - Returns: 盤上に置かれたディスクの枚数が多い方の色です。引き分けの場合は `nil` を返します。
    func dominantSide() -> Disk? {
        
        let darkCount = diskCount(of: .dark)
        let lightCount = diskCount(of: .light)
        
        if darkCount == lightCount {
            return nil
        } else {
            return darkCount > lightCount ? .dark : .light
        }
    }
    
    /// `side` で指定された色のディスクが盤上に置かれている枚数を返します。
    /// - Parameter side: 数えるディスクの色です。
    /// - Returns: `side` で指定された色のディスクの、盤上の枚数です。
    func diskCount(of side: Disk) -> Int {
        
        return board.count(of: side)
    }
}

extension GameController {
    
    /// "Computer" が選択されている場合のプレイヤーの行動を決定します。
    func playTurnOfComputer() {
        
        guard let turn = turnController.currentTurn else { preconditionFailure() }
        
        guard let location = validMoves(for: turn).randomElement() else {
            
            return
        }
        
        delegate?.gameController(self, ponderingWillStartBySide: turn)
        
        let cleanUp: () -> Void = { [weak self] in
            guard let self = self else { return }
            
            self.playerCancellers[turn] = nil
            
            self.delegate?.gameController(self, ponderingDidEndBySide: turn)
        }
        let canceller = Canceller(cleanUp)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            if canceller.isCancelled { return }
            cleanUp()
            
            do {
                
                try self.place(turn, at: location, animated: true, switchToNextTurn: true)
            }
            catch _ {
                
            }
        }
        
        playerCancellers[turn] = canceller
    }
}

extension GameController {
    
    /// ゲームの状態をファイルに書き出し、保存します。
    func saveGame() throws {
        
        try fileController.writeToFile {
            
            turnController.currentState     // Turn
            playerController.players        // Players
            board                           // Board
        }
    }
    
    /// ゲームの状態をファイルから読み込み、復元します。
    func loadGame() throws {
        
        let input = try fileController.readFromFile()

        do {
            
            let deserialized = try Deserializer.deserialization(input)
            
            // Turn
            switch deserialized.turn {
                
                case .playing(side: let side):
                    turnController.turnChange(to: side, reason: .resume)
                    
                case .over:
                    turnController.turnReset()
            }
            
            // Players
            for side in Disk.sides {

                playerController.changePlayer(of: side, to: deserialized.players[of: side])
            }
            
            // Board
            board = deserialized.board
        }
        catch {
        
            throw FileIOError.read(path: fileController.file, cause: error)
        }
        
        allowPlacingOnThisTurn = true
        
        if turnController.isGameOver {

            delegate?.gameController(self, gameOverWithWinner: GameRecord(winner: dominantSide()), board: board)
        }
        else {
            
            delegate?.gameController(self, gameDidStartWithBoard: board, turn: turnController.currentTurn!, players: playerController.players)
        }
    }
    
    /// `location` で指定されたセルに、 `disk` が置けるかを調べます。
    /// ディスクを置くためには、少なくとも 1 枚のディスクをひっくり返せる必要があります。
    /// - Parameter location: セルの位置です。
    /// - Returns: 指定されたセルに `disk` を置ける場合は `true` を、置けない場合は `false` を返します。
    func canPlaceDisk(_ disk: Disk, at location: Location) -> Bool {
        !flipLocationsBy(disk, at: location).isEmpty
    }
    
    /// `side` で指定した側が次の一手を持っているか調べます。
    /// - Parameter side: 対象となる色です。
    /// - Returns: 次の一手を打てる場合に `true` を、そうでなければ `false` を返します。
    func nextMoveAvailable(on side: Disk) -> Bool {
        
        return !validMoves(for: side).isEmpty
    }
    
    /// `side` で指定された色のディスクを置ける盤上のセルの座標をすべて返します。
    /// - Returns: `side` で指定された色のディスクを置ける盤上のすべてのセルの座標の配列です。
    func validMoves(for side: Disk) -> [Location] {
        var locations: [Location] = []
        
        for square in board.squares {
            if canPlaceDisk(side, at: square.location) {
                locations.append(square.location)
            }
        }
        
        return locations
    }
    
    /// `side` で指定した側のプレイヤーを取得します。
    /// - Parameter side: 対象のディスクの色を指定します。
    /// - Returns: 該当するプレイヤーを取得します。
    func player(of side: Disk) -> Player {
        
        return playerController.players[of: side]
    }
    
    /// プレイヤーの行動後、そのプレイヤーのターンを終了して次のターンを開始します。
    func nextTurn(withReason reason: TurnController.ChangedReason) {
        
        guard let newSide = turnController.currentTurn?.flipped else {
        
            return
        }
        
        turnController.turnChange(to: newSide, reason: reason)
        try? saveGame()

        if turnController.isGameOver {
            
            delegate?.gameController(self, gameOverWithWinner: GameRecord(winner: dominantSide()), board: board)
        }
        else {
            
            delegate?.gameController(self, turnChanged: newSide)
        }
    }
    
    /// `location` で指定されたセルに、現在のターンの置きます。
    /// - Parameter location: セルの位置です。
    /// - Parameter isAnimated: ディスクを置いたりひっくり返したりするアニメーションを表示するかどうかを指定します。
    /// - Throws: もし `disk` を `location` で指定されるセルに置けない場合、 `DiskPlacementError` を `throw` します。
    func placeDisk(at location: Location, animated isAnimated: Bool, switchToNextTurn: Bool) throws {
        
        guard let turn = turnController.currentTurn, player(of: turn) == .manual else {
            
            return
        }
        
        try place(turn, at: location, animated: isAnimated, switchToNextTurn: switchToNextTurn)
    }
    
    /// `location` で指定されたセルに `disk` を置きます。
    /// - Parameter location: セルの位置です。
    /// - Parameter isAnimated: ディスクを置いたりひっくり返したりするアニメーションを表示するかどうかを指定します。
    /// - Throws: もし `disk` を `location` で指定されるセルに置けない場合、 `DiskPlacementError` を `throw` します。
    func place(_ disk: Disk, at location: Location, animated isAnimated: Bool, switchToNextTurn: Bool) throws {
        
        guard allowPlacingOnThisTurn else {
            
            return
        }
        
        let flipLocations = flipLocationsBy(disk, at: location)
        
        guard !flipLocations.isEmpty else {
            throw DiskPlacementError(disk: disk, location: location)
        }
        
        allowPlacingOnThisTurn = false
        
        let locations = [location] + flipLocations
        let duration = isAnimated ? animationDuration : 0
        
        for location in locations {
            
            set(Square.State(from: disk), at: location, animationDuration: duration)
        }
        
        try? saveGame()
        delegate?.gameController(self, boardChanged: board, moves: locations, animationDuration: duration)
        
        if switchToNextTurn {
            
            let delay = animationDuration * Double(locations.count)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                
                self.allowPlacingOnThisTurn = true
            }
            
            nextTurn(withReason: .moved)
            waitForPlayer(afterDelay: delay)
            
        }
        else {
            
            allowPlacingOnThisTurn = true
        }
    }
}

private extension GameController {
    
    func flipLocationsBy(_ disk: Disk, at location: Location) -> [Location] {
        
        guard self.disk(at: location) == nil else {
            return []
        }
        
        var diskLocations: [Location] = []
        
        for direction in Direction.allDirections {
            
            var location = location
            var diskLocationsInLine: [Location] = []
            
            flipping: while true {
                
                location = location.next(to: direction)
                
                guard board.contains(location) else {
                    
                    break flipping
                }
                
                switch (disk, self.disk(at: location)) { // Uses tuples to make patterns exhaustive
                case (.dark, .dark), (.light, .light):
                    diskLocations.append(contentsOf: diskLocationsInLine)
                    break flipping
                case (.dark, .light), (.light, .dark):
                    diskLocationsInLine.append(location)
                case (_, .none):
                    break flipping
                }
            }
        }
        
        return diskLocations
    }
}

// MARK: Additional types

final class Canceller {
    private(set) var isCancelled: Bool = false
    private let body: (() -> Void)?
    
    init(_ body: (() -> Void)?) {
        self.body = body
    }
    
    func cancel() {
        if isCancelled { return }
        isCancelled = true
        body?()
    }
}

struct DiskPlacementError: Error {
    let disk: Disk
    let location: Location
}

