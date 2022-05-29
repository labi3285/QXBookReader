//
//  QXBookReaderConfigs.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/11.
//

import UIKit

public struct QXBookReaderConfigs {
    
    /// 按钮/状态 主题色
    public static var tintColor: UIColor = QXBookUtils.hexColor("fd5567")
    
    /// 标题颜色
    public static var titleColor: UIColor = QXBookReaderUtils.hexColor("#333333", darkHex: "#efefef")
    /// 文本颜色
    public static var textColor: UIColor = QXBookReaderUtils.hexColor("#666666", darkHex: "#999999")
    /// 副文本颜色
    public static var subTextColor: UIColor = QXBookReaderUtils.hexColor("#999999", darkHex: "#666666")

    /// 按钮颜色
    public static var buttonTitleColor: UIColor = QXBookReaderUtils.hexColor("#333333", darkHex: "#efefef")
    /// 按钮边框颜色
    public static var buttonBorderColor: UIColor = QXBookReaderUtils.hexColor("#666666", darkHex: "#999999")
    
    /// 背景颜色
    public static var backgroundColor = QXBookReaderUtils.hexColor("#ffffff", darkHex: "#000000")
    /// 导航/浮层背景色
    public static var barBackgroundColor = QXBookReaderUtils.hexColor("#f6f5f5", darkHex: "#1c1c1c")
    /// 浅灰色背景
    public static var backgroundLightGrayColor = QXBookReaderUtils.hexColor("#f6f5f5", darkHex: "#1c1c1c")
    /// 导航/浮层阴影颜色
    public static var barShadowColor = QXBookReaderUtils.hexColor("#000000", darkHex: "#1c1c1c")
    
    /// 遮罩深色
    public static var deepMaskColor = QXBookReaderUtils.hexColor("#000000 0.5", darkHex: "#000000 0.5")

    /// 分割线颜色
    public static var breakLineColor = QXBookReaderUtils.hexColor("#e0e0e0", darkHex: "#3d3d41")
    
    
    /// 用户记录内容路径
    public static var userRecordsPath: String = {
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            return "\(path)/QXBookUserRecords"
        }
        if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            return "\(path)/QXBookUserRecords"
        }
        return "\(NSTemporaryDirectory())QXBookUserRecords"
    }()
    /// 缓存路径
    public static var cachePath: String = {
        if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            return "\(path)/QXBookUserCache"
        }
        return "\(NSTemporaryDirectory())QXBookUserCache"
    }()


}
