//
//  QXBook.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/10.
//

import Foundation


public enum QXBookType: String {
    case txt = "txt"
    case epub = "epub"
}

public class QXBook {
    
    public let bookType: QXBookType
    public let bookName: String
        
    public init(bookType: QXBookType, bookName: String) {
        self.bookType = bookType
        self.bookName = bookName
    }
    
    public var indexes: [QXBookIndex] = []
    
    public var chapters: [QXBookChapter] = []
    
    public var identifier: String?
    public var version: String?
    public var title: String?
    public var language: String?
    public var author: String?
    public var contributor: String?
    public var publisher: String?
    public var description: String?
    public var subject: String?
    public var rights: String?
    public var date: String?
    
    public var coverId: String?
    
    public var resourceBaseFolder: String?
    public var resources: [QXBookResource]?

}

extension QXBook {
    
    public static func fromDictionary(_ dic: [String: Any]) -> QXBook? {
        guard let typeRaw = dic["bookType"] as? String else {  return nil }
        guard let type = QXBookType(rawValue: typeRaw) else {  return nil }
        guard let bookName = dic["bookName"] as? String else {  return nil }
        guard let indexes = dic["indexes"] as? [[String: Any]] else {  return nil }
        let book = QXBook(bookType: type, bookName: bookName)
        book.indexes = indexes.compactMap({ QXBookIndex.fromDictionary($0) })
        return book
    }
    public func toDictionary() -> [String: Any] {
        return [
            "bookType": bookType.rawValue,
            "bookName": bookName,
            "indexes": indexes.map({ $0.toDictionary() })
        ]
    }
    
}
