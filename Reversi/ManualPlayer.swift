//
//  ManualPlayer.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/05/12.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

class ManualPlayer : Player {

    var type: PlayerType {
        
        return .manual
    }
    
    weak var delegate: PlayerDelegate?
    
    required init(withDelegate delegate: PlayerDelegate?) {
        
        self.delegate = delegate
    }
    
    func select(location: Location) {
        
        delegate?.player(self, thinkingDidEndByItself: PlayerThought(state: .specified(location)))
    }
    
    func startThinking(withSide side: Disk, board: Board) {
        
        if !board.nextMoveAvailable(on: side) {
            
            delegate?.player(self, thinkingDidEndByItself: PlayerThought(state: .passed))
        }
    }
    
    func stopThinking() {
        
    }
}
