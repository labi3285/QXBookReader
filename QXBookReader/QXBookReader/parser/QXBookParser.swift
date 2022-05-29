//
//  QXBookParser.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/10.
//

import UIKit

public struct QXBookParser {
    
    public static func parseBook(_ filePath: String, options: QXBookOptions) -> QXBookParserResult<QXBook> {
        if filePath.hasSuffix("." + QXBookType.txt.rawValue) {
            return QXBookTxtParser().parseBook(filePath, options: options)
        } else if filePath.hasSuffix("." + QXBookType.epub.rawValue) {
            return QXBookEpubParser().parseBook(filePath, options: options)
        } else {
            return .error(QXBookParserError(message: "暂未支持格式"))
        }
    }
     
}
