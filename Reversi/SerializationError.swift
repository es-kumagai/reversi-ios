//
//  SerializationError.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/27.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

/// 直列化でエラーが発生したことを表現する型です。
enum SerializationError : Error {
    
    case serializationFailure(String)
    case deserializationFailure(String)
}
