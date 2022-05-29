//
//  QXBookChapter.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/17.
//

import Foundation

public class QXBookChapter {
            
    public let title: String
    public let reference: QXBookReference
            
    public init(title: String, reference: QXBookReference) {
        self.title = title
        self.reference = reference
    }
    
}

public func == (lhs: QXBookChapter, rhs: QXBookChapter) -> Bool {
    switch lhs.reference {
    case .txt(let a):
        switch rhs.reference {
        case .txt(let b):
            return a == b
        case .resource(_):
            return false
        }
    case .resource(let a):
        switch rhs.reference {
        case .txt(_):
            return false
        case .resource(let b):
            return a.id == b.id
        }
    }
}
