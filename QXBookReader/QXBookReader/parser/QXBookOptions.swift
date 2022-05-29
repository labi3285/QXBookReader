//
//  QXBookAttributes.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/10.
//

import UIKit

public class QXBookOptions {
    
    public let cachePath: String
    
    public var titleFontName: String = "PingFang SC"
    public var titleFontSize: Int = 24
    public var titleColor: UIColor = QXBookUtils.hexColor("#333333")
    
    public var textFontName: String = "PingFang SC"
    public var textFontSize: Int = 16
    public var textColor: UIColor = QXBookUtils.hexColor("#666666")
    public var linkColor: UIColor = QXBookUtils.hexColor("#0000ff")

    public var lineHeightRate: CGFloat = 1.2

    public init(cachePath: String) {
        self.cachePath = cachePath
    }
    
}
