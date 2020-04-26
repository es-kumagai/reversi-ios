//
//  FileController.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/26.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

enum FileIOError: Error {

    case write(path: String, cause: Error?)
    case read(path: String, cause: Error?)
}

class FileController : NSObject {
    
    var file: String!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        file = (NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent("Game")
    }
}

extension FileController {
    
    func readFromFile() throws -> String {
        
        return try String(contentsOfFile: file, encoding: .utf8)
    }
    
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
