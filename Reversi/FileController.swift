//
//  FileController.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/26.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// ファイル入出力のエラーを表現する型です。
///
/// write:  書き込みエラー
/// read:   読み込みエラー
enum FileIOError: Error {

    case write(path: String, cause: Error?)
    case read(path: String, cause: Error?)
}

/// ファイルを管理するコントローラーです。
class FileController : NSObject {
    
    var file: String!
    
    /// ストーリーボードから呼び出される初期化です。
    override func awakeFromNib() {
        
        super.awakeFromNib()

        file = (NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent("Game")
    }
}

extension FileController {
    
    /// ファイルからデータを読み込みます。
    /// - Throws:
    /// - Returns: ファイルの内容を文字列で返します。
    func readFromFile() throws -> String {
        
        return try String(contentsOfFile: file, encoding: .utf8)
    }
    
    /// ファイルにデータを書き込みます。
    /// - Parameter contents: 書き込むコンテンツを文字列で指定します。
    /// - Throws: 
    func writeToFile(@Serialization contents: () -> String) throws {
        
        do {
            
            let serialized = contents()
            try serialized.write(toFile: file, atomically: true, encoding: .utf8)
        }
        catch {

            throw FileIOError.read(path: file, cause: error)
        }
    }
}
