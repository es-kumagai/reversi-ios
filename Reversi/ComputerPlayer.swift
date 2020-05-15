//
//  ComputerPlayer.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

class ComputerPlayer : Player {
    
    /// 思考を進めている最中の時に `true`、そうでなければ `false` になります。
    private var isThinking = false
    
    /// 思考を行うスレッドです。
    private var thinkingQueue = DispatchQueue(label: "reversi.playercontroller.thinking")
    
    var type: PlayerMode {
        
        return .computer
    }
    
    weak var delegate: PlayerDelegate?
    
    required init(withDelegate delegate: PlayerDelegate?) {
        
        self.delegate = delegate
    }
    
    func select(location: Location) {
        
    }
    
    func startThinking(withSide side: Disk, board: Board) {

        guard !isThinking else {
            
            return
        }
        
        guard board.nextMoveAvailable(on: side) else {
            
            delegate?.player(self, thinkingDidEndByItself: PlayerThought(state: .passed))
            return
        }

        isThinking = true
        
        delegate?.playerThinkingWillStartByItself(self)
        
        thinkingQueue.async {
            
            self.thinking(withSide: side, board: board)
        }
    }
    
    func stopThinking() {
        
        guard isThinking else {
            
            return
        }
        
        isThinking = false
    }
}

fileprivate extension ComputerPlayer {
    
    /// 次の手番を考えます。
    /// - Parameters:
    ///   - side: 自分の手番の色です。
    ///   - board: 現在の盤面です。
    func thinking(withSide side: Disk, board: Board) {
     
        Thread.sleep(forTimeInterval: 2)
        
        guard isThinking else {
        
            DispatchQueue.main.async {

                self.delegate?.player(self, thinkingDidEndByItself: PlayerThought(state: .aborted))
            }
            return
        }
        
        stopThinking()
        
        guard let location = board.validMoves(for: side).randomElement() else {

            DispatchQueue.main.async {

                self.delegate?.player(self, thinkingDidEndByItself: PlayerThought(state: .passed))
            }
            return
        }
        
        DispatchQueue.main.async {
            
            self.delegate?.player(self, thinkingDidEndByItself: PlayerThought(state: .moved(location)))
        }
    }
}
