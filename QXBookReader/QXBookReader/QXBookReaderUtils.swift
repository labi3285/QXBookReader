//
//  QXBookReaderUtils.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/10.
//

import UIKit

public struct QXBookReaderUtils {
    
    public static func getStringValueFromUserDefaults(_ key: String) -> String? {
        return UserDefaults.standard.value(forKey: key) as? String
    }
    public static func getIntValueFromUserDefaults(_ key: String) -> Int? {
        return UserDefaults.standard.value(forKey: key) as? Int
    }
    public static func getCGFloatValueFromUserDefaults(_ key: String) -> CGFloat? {
        return UserDefaults.standard.value(forKey: key) as? CGFloat
    }
    public static func setValueToUserDefaults(value: Any, key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public static func getStatusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    public static func getBottomAppendHeight() -> CGFloat {
        return getStatusBarHeight() == 20 ? 0 : 20
    }
    
    public static func getIsDarkMode() -> Bool {
        if #available(iOS 13.0, *) {
            switch UITraitCollection.current.userInterfaceStyle {
            case .dark:
                return true
            default:
                return false
            }
        } else {
            return false
        }
    }
    
    public static func hexColor(_ hex: String, darkHex: String) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { c in
                switch c.userInterfaceStyle {
                case .dark:
                    return QXBookUtils.hexColor(darkHex)
                default:
                    return QXBookUtils.hexColor(hex)
                }
            })
        } else {
            return QXBookUtils.hexColor(hex)
        }
    }
    
    public static func screenShot(_ view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 1)
        if let ctx = UIGraphicsGetCurrentContext() {
            view.layer.render(in: ctx)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return image
            }
        }
        return nil
    }
    
    public static func getCGAffineTransform(_ rect: CGRect, targetRect: CGRect) -> CGAffineTransform {
        let _scaleX = targetRect.width / rect.width
        let _scaleY = targetRect.height / rect.height
        let _deltaX = (targetRect.midX - rect.midX) / _scaleX
        let _deltaY = (targetRect.midY - rect.midY) / _scaleY
        return CGAffineTransform(scaleX: _scaleX, y: _scaleY).translatedBy(x: _deltaX, y: _deltaY)
    }
        
    public static func getNatureDateString(_ date: Date) -> String {
        let seconds: Int = Int(date.timeIntervalSince1970 - Date().timeIntervalSince1970)
        if (abs(seconds / 3600) < 1) {
            let minutes = seconds / 60
            if abs(minutes) <= 0 {
                return "刚刚"
            } else {
                if minutes > 0 {
                    return "\(minutes)" + "分钟后"
                } else {
                    return "\(-minutes)" + "分钟前"
                }
            }
        }
        else if abs(seconds / 86400) < 1 {
            let hours = seconds / 3600
            if hours > 0 {
                return "\(hours)" + "小时后"
            } else {
                return "\(-hours)" + "小时前"
            }
        }
        else {
            let days = seconds / 86400
            if abs(days) <= 1 {
                if days > 0 {
                    return "明天"
                } else {
                    return "昨天"
                }
            } else if abs(days) == 2 {
                if days > 0 {
                    return "后天"
                } else {
                    return "前天"
                }
            } else if abs(days) <= 7 {
                if days > 0 {
                    return "\(days)" + "天后"
                } else {
                    return "\(-days)" + "天前"
                }
            } else if abs(days) <= 30 {
                if days > 0 {
                    return "\(days / 7)" + "周后"
                } else {
                    return "\(-days / 7)" + "周前"
                }
            } else if abs(days) < 365 {
                if days > 0 {
                    return "\(days / 30)" + "月后"
                } else {
                    return "\(-days / 30)" + "月前"
                }
            } else {
                if days > 0 {
                    return "\(days / 365)" + "年后"
                } else {
                    return "\(-days / 365)" + "年前"
                }
            }
        }
    }
    
}
