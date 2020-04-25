//
//  ComputerPlayer.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/25.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

class ComputerPlayer : Player {
    
    var side: Disk
    
    init(side: Disk) {
        
        self.side = side
        
    }
    
    func abortThinking() {
        
    }
}
