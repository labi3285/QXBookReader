//
//  QXBookReaderTheme.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/11.
//

import UIKit

public struct QXBookReaderTheme {
    
    public let code: String
    public let isDark: Bool
    public let backgroundColor: UIColor
    public let titleColor: UIColor
    public let textColor: UIColor
    public let linkColor: UIColor

    public init(code: String, isDark: Bool, backgroundColorHex: String, titleColorHex: String, textColorHex: String, linkColorHex: String) {
        self.code = code
        self.isDark = isDark
        self.backgroundColor = QXBookUtils.hexColor(backgroundColorHex)
        self.titleColor = QXBookUtils.hexColor(titleColorHex)
        self.textColor = QXBookUtils.hexColor(textColorHex)
        self.linkColor = QXBookUtils.hexColor(linkColorHex)
    }
    
    public static let themes: [QXBookReaderTheme] = [
        QXBookReaderTheme(code: "normal",
                          isDark: false,
                          backgroundColorHex: "#ffffff",
                          titleColorHex: "#333333",
                          textColorHex: "#666666",
                          linkColorHex: "#0000ff"),
        QXBookReaderTheme(code: "gray",
                          isDark: true,
                          backgroundColorHex: "#393536",
                          titleColorHex: "#969293",
                          textColorHex: "#969293",
                          linkColorHex: "#0000ff"),
        QXBookReaderTheme(code: "night",
                          isDark: true,
                          backgroundColorHex: "#061c29",
                          titleColorHex: "#526875",
                          textColorHex: "#526875",
                          linkColorHex: "#0000ff"),
        QXBookReaderTheme(code: "papper",
                          isDark: false,
                          backgroundColorHex: "#f7dcaf",
                          titleColorHex: "#734222",
                          textColorHex: "#734222",
                          linkColorHex: "#0000ff"),
        QXBookReaderTheme(code: "flower",
                          isDark: false,
                          backgroundColorHex: "#ffe7e7",
                          titleColorHex: "#723948",
                          textColorHex: "#723948",
                          linkColorHex: "#0000ff"),
        QXBookReaderTheme(code: "grass",
                          isDark: false,
                          backgroundColorHex: "#d6efd2",
                          titleColorHex: "#2d4c2d",
                          textColorHex: "#2d4c2d",
                          linkColorHex: "#0000ff"),
    ]
    
}
