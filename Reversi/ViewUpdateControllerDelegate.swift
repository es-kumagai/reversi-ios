//
//  ViewUpdateControllerDelegate.swift
//  Reversi
//
//  Created by kumagai on 2020/04/27.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

@objc protocol ViewUpdateControllerDelegate : class {
    
    func viewUpdateController(_ controller: ViewUpdateController, updateSquare state: Square.State, location: Location, animated: Bool)
    func viewUpdateController(_ controller: ViewUpdateController, updateBoard board: Board, animated: Bool)
}
