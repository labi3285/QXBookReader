//
//  QXBookIndex.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/10.
//

import Foundation

public enum QXBookReference {
    case txt(String)
    case resource(QXBookResource)
    
    public func toString() -> String {
        switch self {
        case .txt(let e):
            return e
        case .resource(_):
            fatalError("not here")
        }
    }
}


public class QXBookIndex {
        
    public var level: Int { return _level }
    public var tag: String? { return _tag }

    public let title: String
    public let reference: QXBookReference
    
    var _children: [QXBookIndex]?
    var _level: Int = 1
        
    var _tag: String?
    
    public var chapter: QXBookChapter {
        return QXBookChapter(title: title, reference: reference)
    }
        
    public init(title: String, reference: QXBookReference) {
        self.title = title
        self.reference = reference
    }
    
}

extension QXBookIndex {
    
    public static func fromDictionary(_ dic: [String: Any]) -> QXBookIndex? {
        guard let title = dic["title"] as? String else {  return nil }
        guard let subPath = dic["subPath"] as? String else {  return nil }
        let e = QXBookIndex(title: title, reference: QXBookReference.txt(subPath))
        return e
    }
    public func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "subPath": reference.toString()
        ]
    }
    
}

public func == (lhs: QXBookIndex, rhs: QXBookIndex) -> Bool {
    switch lhs.reference {
    case .txt(let a):
        switch rhs.reference {
        case .txt(let b):
            return a == b && (lhs.tag ?? "") == (rhs.tag ?? "")
        case .resource(_):
            return false
        }
    case .resource(let a):
        switch rhs.reference {
        case .txt(_):
            return false
        case .resource(let b):
            return a.id == b.id && (lhs.tag ?? "") == (rhs.tag ?? "")
        }
    }
}
