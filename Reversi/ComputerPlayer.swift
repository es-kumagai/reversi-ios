//
//  ComputerPlayer.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

class ComputerPlayer : Player {

    private var isThinking = false
    private var thinkingQueue = DispatchQueue(label: "reversi.playercontroller.thinking")
    
    var type: PlayerType {
        
        return .manual
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
