//
//  QXBookTxtParser.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/14.
//

import UIKit

public struct QXBookTxtParser {
    
    public func parseBook(_ txtFilePath: String, options: QXBookOptions) -> QXBookParserResult<QXBook> {
        let bookName = QXBookUtils.getFileName(filePath: txtFilePath)
        let bookCacheFolderPath = "\(options.cachePath)/\(bookName).txt.cache"
        let bookCachePath = "\(bookCacheFolderPath)/book.json"
        if QXBookUtils.checkFileOrFolderPathExists(bookCacheFolderPath) {
            if let json = try? String(contentsOfFile: bookCachePath), let dic = QXBookUtils.jsonStringToDictionary(json) {
                if let book = QXBook.fromDictionary(dic) {
                    book.chapters = book.indexes.map({ $0.chapter })
                    return QXBookParserResult.ok(book)
                } else {
                    return _parseTxt(txtFilePath, options: options)
                }
            } else {
                return _parseTxt(txtFilePath, options: options)
            }
        }
        return _parseTxt(txtFilePath, options: options)
    }

    private func _parseTxt(_ txtFilePath: String, options: QXBookOptions) -> QXBookParserResult<QXBook> {
        let bookName = QXBookUtils.getFileName(filePath: txtFilePath)
        if bookName.count == 0 {
            return QXBookParserResult.error(QXBookParserError(message: "文件名错误"))
        }
        guard let encodedText = QXBookUtils.getEncodedText(txtFilePath) else {
            return QXBookParserResult.error(QXBookParserError(message: "文件解析失败"))
        }
        let book = QXBook(bookType: .txt, bookName: bookName)
        let bookCacheFolderPath = "\(options.cachePath)/\(bookName).txt.cache"
        if let err = QXBookUtils.checkOrMakeFolder(bookCacheFolderPath) {
            return QXBookParserResult.error(QXBookParserError(message: "文件缓存失败:\(err.localizedDescription)"))
        }
        let text = _formatText(encodedText)
        let pattern =
            "((第[0-9零一二三四五六七八九十百千壹贰叁肆伍陆柒捌玖拾佰仟]+)([章回])(.*))"
//            + "|" +
//            "(([零一二三四五六七八九十百千壹贰叁肆伍陆柒捌玖拾佰仟])(、)(.*))"
        let matches = QXBookUtils.regularMatch(text, pattern: pattern)
        if matches.count > 0 {
            var _index: Int = 0
            let first = matches.first!
            // 前言
            if first.range.location > 0 {
                let range = NSMakeRange(0, first.range.location)
                let chapterText = QXBookUtils.getSubString(text, with: range)
                let chapterSubPath = "chapter_\(_index).txt"
                if let err = QXBookUtils.saveToFile(chapterText, filePath: "\(bookCacheFolderPath)/\(chapterSubPath)") {
                    return QXBookParserResult.error(QXBookParserError(message: "文件缓存失败:\(err.localizedDescription)"))
                }
                let index = QXBookIndex(title: "前言", reference: .txt(chapterSubPath))
                book.indexes.append(index)
                _index += 1
            }
            for (i, r) in matches.enumerated() {
                let title = QXBookUtils.getSubString(text, with: r.range)
                let start = r.range.location + r.range.length
                let end = i < matches.count - 1 ? matches[i + 1].range.location : (text as NSString).length
                let range = NSMakeRange(start, end - start)
                let chapterText = QXBookUtils.getSubString(text, with: range)
                let chapterSubPath = "chapter_\(_index).txt"
                if let err = QXBookUtils.saveToFile(chapterText, filePath: "\(bookCacheFolderPath)/\(chapterSubPath)") {
                    return QXBookParserResult.error(QXBookParserError(message: "文件缓存失败:\(err.localizedDescription)"))
                }
                let index = QXBookIndex(title: title, reference: .txt(chapterSubPath))
                book.indexes.append(index)
                _index += 1
            }
        } else {
            let range = NSMakeRange(0, (text as NSString).length)
            let chapterText = QXBookUtils.getSubString(text, with: range)
            let chapterSubPath = "chapter_\(0).txt"
            if let err = QXBookUtils.saveToFile(chapterText, filePath: "\(bookCacheFolderPath)/\(chapterSubPath)") {
                return QXBookParserResult.error(QXBookParserError(message: "文件缓存失败:\(err.localizedDescription)"))
            }
            let index = QXBookIndex(title: "正文", reference: .txt(chapterSubPath))
            book.indexes.append(index)
        }
        book.chapters = book.indexes.map({ $0.chapter })
        if let json = QXBookUtils.dictionaryToJsonString(book.toDictionary()) {
            let bookCachePath = "\(bookCacheFolderPath)/book.json"
            if let err = QXBookUtils.saveToFile(json, filePath: bookCachePath) {
                return QXBookParserResult.error(QXBookParserError(message: "文件缓存失败:\(err.localizedDescription)"))
            }
        } else {
            return QXBookParserResult.error(QXBookParserError(message: "文件缓存失败:序列号失败"))
        }
        return QXBookParserResult.ok(book)
    }
    private func _formatText(_ originText: String) -> String {
        var t = originText
        t = t.replacingOccurrences(of: "\r", with: "")
        t = QXBookUtils.regularReplace(t, pattern: "\\s*\\n+\\s*", with: "\n　　")
        return t
    }
    
}

