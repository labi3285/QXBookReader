//
//  QXBookUtils.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/10.
//

import UIKit

public struct QXBookUtils {
    
    public static func hexColor(_ hex: String) -> UIColor {
        func hex2rgb(_ hex: String) -> (r: UInt8, g: UInt8, b: UInt8) {
            var t = hex.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines).uppercased()
            t = t.replacingOccurrences(of: "#", with: "")
            if (t.count != 6) {
                return (0, 0, 0)
            } else {
                var r: CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0
                Scanner(string: (t as NSString).substring(with: NSRange(location: 0, length: 2))).scanHexInt32(&r)
                Scanner(string: (t as NSString).substring(with: NSRange(location: 2, length: 2))).scanHexInt32(&g)
                Scanner(string: (t as NSString).substring(with: NSRange(location: 4, length: 2))).scanHexInt32(&b)
                return (UInt8(r), UInt8(g), UInt8(b))
            }
        }
        let components = hex.components(separatedBy: " ")
        if components.count == 1 {
            let rgb = hex2rgb(hex)
            return UIColor(red: CGFloat(rgb.r) / 255, green: CGFloat(rgb.g) / 255, blue: CGFloat(rgb.b) / 255, alpha: 1)
        } else if components.count == 2 {
            let rgb = hex2rgb(components[0])
            if components[1].contains("%") {
                let alpha = CGFloat((components[1].replacingOccurrences(of: "%", with: "") as NSString).floatValue) / 100
                return UIColor(red: CGFloat(rgb.r) / 255, green: CGFloat(rgb.g) / 255, blue: CGFloat(rgb.b) / 255, alpha: alpha)
            } else {
                let alpha = min(CGFloat((components[1] as NSString).floatValue), 1)
                return UIColor(red: CGFloat(rgb.r) / 255, green: CGFloat(rgb.g) / 255, blue: CGFloat(rgb.b) / 255, alpha: alpha)
            }
        }
        return UIColor.black
    }
    
    public static func getFileNameWithExt(filePath: String) -> String {
        return (filePath as NSString).lastPathComponent
    }
    public static func getFileName(filePath: String) -> String {
        return (getFileNameWithExt(filePath: filePath) as NSString).deletingPathExtension
    }
    public static func getFileDir(filePath: String) -> String {
        return (getFileNameWithExt(filePath: filePath) as NSString).deletingLastPathComponent
    }
    public static func getSubString(_ text: String, with range: NSRange) -> String {
        return (text as NSString).substring(with: range)
    }
    public static func regularReplace(_ text: String, pattern: String, with: String) -> String {
        do {
            let regularExpression = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            return regularExpression.stringByReplacingMatches(in: text, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (text as NSString).length), withTemplate: with)
        } catch {
        }
        return text
    }
    public static func regularMatch(_ text: String, pattern: String) -> [NSTextCheckingResult] {
        do {
            let regularExpression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            return regularExpression.matches(in: text, options: .reportCompletion, range: NSRange(location: 0, length: (text as NSString).length))
        } catch {
        }
        return []
    }
    
    public static func getEncodedText(_ txtFilePath: String) -> String? {
        func _getEncodedTxt(_ txtFilePath: String, encoding:UInt) -> String? {
            do {
                return try NSString(contentsOfFile: txtFilePath, encoding: encoding) as String
            } catch {
                return nil
            }
        }
        if let t = _getEncodedTxt(txtFilePath, encoding: String.Encoding.utf8.rawValue) {
            return t
        } else if let t = _getEncodedTxt(txtFilePath, encoding: 0x80000632) {
            return t
        } else if let t = _getEncodedTxt(txtFilePath, encoding: 0x80000631) {
            return t
        }
        return nil
    }
    
    
    public static func dictionaryToJsonString(_ dic: [String: Any]) -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: dic, options: .init(rawValue: 0)) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    public static func arrayToJsonString(_ arr: [[String: Any]]) -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: arr, options: .init(rawValue: 0)) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    public static func jsonStringToDictionary(_ jsonStr: String) -> [String: Any]? {
        if let data = jsonStr.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
        }
        return nil
    }
    public static func jsonStringToArray(_ jsonStr: String) -> [[String: Any]]? {
        if let data = jsonStr.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]]
        }
        return nil
    }
     
    public static func saveToFile(_ text: String, filePath: String) -> Error? {
        do {
            try text.write(toFile: filePath, atomically: true, encoding: .utf8)
            return nil
        } catch {
            return error
        }
    }
    
    public static func checkOrMakeFolder(_ folderPath: String) -> Error? {
        if checkFileOrFolderPathExists(folderPath) {
            return nil
        } else {
            do {
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                return nil
            } catch {
                return error
            }
        }
    }
    public static func checkFileOrFolderPathExists(_ path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
}
