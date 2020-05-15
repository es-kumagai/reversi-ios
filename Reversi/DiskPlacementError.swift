//
//  DiskPlacementError.swift
//  Reversi
//
//  Created by kumagai on 2020/05/15.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

struct DiskPlacementError: Error {
    let disk: Disk
    let location: Location
}
