//
//  QXBookPageMark.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/14.
//

import UIKit

public class QXBookPageMark {
    
    public let chapterIndex: Int
    public let nodeIndexPath: String
    
    public init(chapterIndex: Int, nodeIndexPath: String) {
        self.chapterIndex = chapterIndex
        self.nodeIndexPath = nodeIndexPath
    }
    
    public var createTime: TimeInterval = 0
    public var chapterTitle: String = ""
    public var content: String = ""
    
}

extension QXBookPageMark {
    
    public static func fromDictionary(_ dic: [String: Any]) -> QXBookPageMark? {
        guard let chapterIndex = dic["chapterIndex"] as? Int else {  return nil }
        guard let nodeIndexPath = dic["nodeIndexPath"] as? String else {  return nil }
        let mark = QXBookPageMark(chapterIndex: chapterIndex, nodeIndexPath: nodeIndexPath)
        mark.chapterTitle = dic["chapterTitle"] as? String ?? ""
        mark.createTime = TimeInterval(dic["createTime"] as? CGFloat ?? 0)
        mark.content = dic["content"] as? String ?? ""
        return mark
    }
    public func toDictionary() -> [String: Any] {
        return [
            "chapterIndex": chapterIndex,
            "nodeIndexPath": nodeIndexPath,
            "chapterTitle": chapterTitle,
            "createTime": createTime,
            "content": content,
        ]
    }
    
}
