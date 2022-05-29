//
//  QXBookEpubParser.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/14.
//

import UIKit
import SSZipArchive
import AEXML

public class QXBookEpubParser: NSObject {
    
    public func parseBook(_ epubFilePath: String, options: QXBookOptions) -> QXBookParserResult<QXBook> {
        let bookName = QXBookUtils.getFileName(filePath: epubFilePath)
        let bookCacheFolderPath = "\(options.cachePath)/\(bookName).epub.cache"
        if !QXBookUtils.checkFileOrFolderPathExists(epubFilePath) {
            return .error(QXBookParserError(message: "路径无效"))
        }
        let isNeedsUnzip = !QXBookUtils.checkFileOrFolderPathExists(bookCacheFolderPath)
        if isNeedsUnzip {
            SSZipArchive.unzipFile(atPath: epubFilePath, toDestination: bookCacheFolderPath, delegate: self)
        }
        let book = QXBook(bookType: .epub, bookName: bookName)
        if let msg = _parseInfoResources(book: book, unzipBookPath: bookCacheFolderPath) {
            return QXBookParserResult.error(QXBookParserError(message: msg))
        }
        return QXBookParserResult.ok(book)
    }
    
    private func _parseInfoResources(book: QXBook, unzipBookPath: String) -> String? {
        var _xmlParseResult: (xml: AEXMLDocument?, msg: String) = (nil, "")
        _xmlParseResult = _parseXML((unzipBookPath as NSString).appendingPathComponent("META-INF/container.xml"))
        guard let containerXml = _xmlParseResult.xml else {
            return _xmlParseResult.msg
        }
        guard let opfSubPath = containerXml.root["rootfiles"]["rootfile"].attributes["full-path"] else {
            return "full-path为空"
        }
        // 获取索引内容
        _xmlParseResult = _parseXML("\(unzipBookPath)/\(opfSubPath)")
        guard let opfXml = _xmlParseResult.xml else {
            return _xmlParseResult.msg
        }
        if let package = opfXml.children.first {
            book.identifier = package.attributes["unique-identifier"]
            if let version = package.attributes["version"] {
                book.version = "\(version)"
            }
        }
        let _resourceBaseFolder = (opfSubPath as NSString).deletingLastPathComponent
        let resourceBaseFolder = _resourceBaseFolder.count > 0 ? _resourceBaseFolder : nil
        // 获取所有资源
        var _resources: [QXBookResource] = []
        if let es = opfXml.root["manifest"]["item"].all, es.count > 0 {
            for e in es {
                if let id = e.attributes["id"], let typeName = e.attributes["media-type"], let _subPath = e.attributes["href"] {
                    let subPath = resourceBaseFolder != nil ? "\(resourceBaseFolder!)/\(_subPath)" : _subPath
                    let type = QXBookResourceType.allTypes.first(where: { $0.name == typeName }) ??
                        QXBookResourceType(name: typeName, defaultExtension: (subPath as NSString).pathExtension)
                    var resource = QXBookResource(id: id, subPath: subPath, type: type)
                    resource.properties = e.attributes["properties"]
                    _resources.append(resource)
                }
            }
        }
        book.resourceBaseFolder = resourceBaseFolder
        book.resources = _resources
    
        // 获取书籍信息
        for e in opfXml.root["metadata"].children {
            if e.name == "dc:title" {
                book.title = e.value
            } else if e.name == "dc:identifier" {
                book.identifier = e.value
            } else if e.name == "dc:language" {
                book.language = e.value
            } else if e.name == "dc:creator" {
                book.author = e.value
            } else if e.name == "dc:contributor" {
                book.contributor = e.value
            } else if e.name == "dc:publisher" {
                book.publisher = e.value
            } else if e.name == "dc:description" {
                book.description = e.value
            } else if e.name == "dc:subject" {
                book.subject = e.value
            } else if e.name == "dc:rights" {
                book.rights = e.value
            } else if e.name == "dc:date" {
                book.date = e.value
            } else if e.name == "meta" {
                if e.attributes["name"] == "cover" {
                    book.coverId = e.attributes["content"]
                }
            }
        }
        
        // 获取书籍索引
        var _tocResource: QXBookResource?
        if let e = _resources.first(where: { $0.type == .ncx  }) {
            _tocResource = e
        } else if let e = _resources.first(where: { $0.type.defaultExtension == QXBookResourceType.ncx.defaultExtension }) {
            _tocResource = e
        } else if let e = _resources.first(where: { $0.properties == "nav" }) {
            _tocResource = e
        }
        if let _tocResource = _tocResource {
            _xmlParseResult = _parseXML("\(unzipBookPath)/\(_tocResource.subPath)")
            guard let tocXml = _xmlParseResult.xml else {
                return _xmlParseResult.msg
            }
            var _tocItems: [AEXMLElement]?
            if _tocResource.type == .ncx {
                if let es = tocXml.root["navMap"]["navPoint"].all {
                    _tocItems = es
                }
            } else {
                if let nav = tocXml.root["body"]["nav"].first, let es = nav["ol"]["li"].all {
                    _tocItems = es
                } else if let nav = _findNavTagFromXMLElement(tocXml.root["body"]), let es = nav["ol"]["li"].all {
                    _tocItems = es
                }
            }
            if let es = _tocItems, es.count > 0 {
                var _arr: [QXBookIndex] = []
                for e in es {
                    if let e = _parseIndex(resourceBaseFolder, _resources, _tocResource, e) {
                        _arr.append(e)
                    }
                }
                var _indexes: [QXBookIndex] = []
                func _flat(_ arr: [QXBookIndex], level: Int) {
                    for a in arr {
                        a._level = level
                        _indexes.append(a)
                        if let arr = a._children, arr.count > 0 {
                            _flat(arr, level: level + 1)
                        }
                    }
                }
                _flat(_arr, level: 0)
                book.indexes = _indexes
            }
        }
        
        // 获取章节列表
        let spine = opfXml.root["spine"]
        if spine.children.count > 0 {
            var _spineResources: [QXBookResource] = []
            for e in spine.children {
                if let id = e.attributes["idref"] {
                    if let r = _resources.first(where: { $0.id == id }) {
                        _spineResources.append(r)
                    }
                }
            }
            var _chapters: [QXBookChapter] = []
            for s in _spineResources {
                var _index: QXBookIndex?
                for e in book.indexes {
                    switch e.reference {
                    case .resource(let r):
                        if r == s {
                            _index = e
                            break
                        }
                    case .txt(_):
                        fatalError("not here")
                        continue
                    }
                }
                if let e = _index {
                    _chapters.append(e.chapter)
                }
            }
            book.chapters = _chapters
        }
            
        return nil
    }
    private func _parseXML(_ xmlFilePath: String) -> (xml: AEXMLDocument?, msg: String) {
        let url = URL(fileURLWithPath: xmlFilePath)
        guard let containerData = try? Data(contentsOf: url) else {
            return (nil, "\(QXBookUtils.getFileNameWithExt(filePath: xmlFilePath))读取失败")
        }
        do {
            let xml = try AEXMLDocument(xml: containerData)
            return (xml, "ok")
        } catch {
            return (nil, "\(QXBookUtils.getFileNameWithExt(filePath: xmlFilePath))解析失败")
        }
    }
    private func _parseIndex(_ resourceBaseFolder: String?, _ resources: [QXBookResource], _ tocResource: QXBookResource, _ navElement: AEXMLElement) -> QXBookIndex? {
        var title = ""
        var referenceStr: String = ""
        if tocResource.type == .ncx {
            if let e = navElement["navLabel"]["text"].value {
                title = e
            }
            guard let _reference = navElement["content"].attributes["src"] else {
                return nil
            }
            referenceStr = _reference
        } else {
            guard let _title = navElement["a"].value, _title.count > 0 else {
                return nil
            }
            title = _title
            guard let _reference = navElement["a"].attributes["href"] else {
                return nil
            }
            referenceStr = _reference
        }
        let _subPathComps = referenceStr.split {$0 == "#"}.map { String($0) }
        if _subPathComps.count == 0 {
            return nil
        }
        let tag = _subPathComps.count > 1 ? _subPathComps[1] : nil
        var _subPath = _subPathComps[0]
        if _subPath.count == 0 {
            return nil
        }
        _subPath = _subPath.replacingOccurrences(of: "../", with: "")
        if let r = resourceBaseFolder {
            _subPath = "\(r)/\(_subPath)"
        }
        let subPath = _subPath
        guard let resource = resources.first(where: { $0.subPath == subPath }) else {
            return nil
        }
        let reference = QXBookReference.resource(resource)
        let index = QXBookIndex(title: title, reference: reference)
        index._tag = tag
        if let navPoints = navElement["navPoint"].all {
            var es: [QXBookIndex] = []
            for e in navPoints {
                if let e = _parseIndex(resourceBaseFolder, resources, tocResource, e) {
                    es.append(e)
                }
            }
            if es.count > 0 {
                index._children = es
            }
        }
        return index
    }
    private func _findNavTagFromXMLElement(_ element: AEXMLElement) -> AEXMLElement? {
        for e in element.children {
            if let nav = e["nav"].first {
                return nav
            } else {
                if let nav = _findNavTagFromXMLElement(e) {
                    return nav
                }
            }
        }
        return nil
    }

    
}

extension QXBookEpubParser: SSZipArchiveDelegate {
    public func zipArchiveWillUnzipArchive(atPath path: String, zipInfo: unz_global_info) {
    }
}
