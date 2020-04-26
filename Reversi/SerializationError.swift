//
//  SerializationError.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/27.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

enum SerializationError : Error {
    
    case serializationFailure(String)
    case deserializationFailure(String)
}
