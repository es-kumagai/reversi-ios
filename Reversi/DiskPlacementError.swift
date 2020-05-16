//
//  DiskPlacementError.swift
//  Reversi
//
//  Created by kumagai on 2020/05/15.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

/// ディスクの置き換え処理で発生するエラーです。
struct DiskPlacementError: Error {
    let disk: Disk
    let location: Location
}
