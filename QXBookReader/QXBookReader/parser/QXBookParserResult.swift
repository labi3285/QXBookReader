//
//  QXBookParserError.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/10.
//

import Foundation

public enum QXBookParserResult<T> {
    case ok(T)
    case error(QXBookParserError)
}

public struct QXBookParserError: Error {
    
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
    
}
