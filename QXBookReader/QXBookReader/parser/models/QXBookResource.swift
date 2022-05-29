//
//  QXBookResource.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/15.
//

import UIKit

public struct QXBookResourceType {
    public let name: String
    public let defaultExtension: String
    public let extensions: [String]
    public init(name: String, defaultExtension: String, extensions: [String] = []) {
        self.name = name
        self.defaultExtension = defaultExtension
        self.extensions = extensions
    }
    
    public static let xhtml = QXBookResourceType(name: "application/xhtml+xml", defaultExtension: "xhtml", extensions: ["htm", "html", "xhtml", "xml"])
    public static let epub = QXBookResourceType(name: "application/epub+zip", defaultExtension: "epub")
    public static let ncx = QXBookResourceType(name: "application/x-dtbncx+xml", defaultExtension: "ncx")
    public static let opf = QXBookResourceType(name: "application/oebps-package+xml", defaultExtension: "opf")
    public static let javaScript = QXBookResourceType(name: "text/javascript", defaultExtension: "js")
    public static let css = QXBookResourceType(name: "text/css", defaultExtension: "css")

    // images
    public static let jpg = QXBookResourceType(name: "image/jpeg", defaultExtension: "jpg", extensions: ["jpg", "jpeg"])
    public static let png = QXBookResourceType(name: "image/png", defaultExtension: "png")
    public static let gif = QXBookResourceType(name: "image/gif", defaultExtension: "gif")
    public static let svg = QXBookResourceType(name: "image/svg+xml", defaultExtension: "svg")

    // fonts
    public static let ttf = QXBookResourceType(name: "application/x-font-ttf", defaultExtension: "ttf")
    public static let ttf1 = QXBookResourceType(name: "application/x-font-truetype", defaultExtension: "ttf")
    public static let ttf2 = QXBookResourceType(name: "application/x-truetype-font", defaultExtension: "ttf")
    public static let openType = QXBookResourceType(name: "application/vnd.ms-opentype", defaultExtension: "otf")
    public static let woff = QXBookResourceType(name: "application/font-woff", defaultExtension: "woff")

    // audio
    public static let mp3 = QXBookResourceType(name: "audio/mpeg", defaultExtension: "mp3")
    public static let mp4 = QXBookResourceType(name: "audio/mp4", defaultExtension: "mp4")
    public static let ogg = QXBookResourceType(name: "audio/ogg", defaultExtension: "ogg")

    public static let smil = QXBookResourceType(name: "application/smil+xml", defaultExtension: "smil")
    public static let xpgt = QXBookResourceType(name: "application/adobe-page-template+xml", defaultExtension: "xpgt")
    public static let pls = QXBookResourceType(name: "application/pls+xml", defaultExtension: "pls")

    public static let allTypes = [xhtml, epub, ncx, opf, jpg, png, gif, javaScript, css, svg, ttf, ttf1, ttf2, openType, woff, mp3, mp4, ogg, smil, xpgt, pls]
}

public func == (lhs: QXBookResourceType, rhs: QXBookResourceType) -> Bool {
    if lhs.name != rhs.name { return false }
    if lhs.defaultExtension != rhs.defaultExtension { return false }
    if lhs.extensions != rhs.extensions { return false }
    return true
}

public struct QXBookResource {

    public let id: String
    public let subPath: String
    public let type: QXBookResourceType
        
    public var properties: String?

    public init(id: String, subPath: String, type: QXBookResourceType) {
        self.id = id
        self.subPath = subPath
        self.type = type
    }
    
}

public func == (lhs: QXBookResource, rhs: QXBookResource) -> Bool {
    return lhs.id == rhs.id
}
