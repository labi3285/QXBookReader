//
//  QXBookReaderResources.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/10.
//

import UIKit

public class QXBookReaderResources {
        
    public static var bundle: Bundle {
        if let e = _bundle {
            return e
        }
        let bundle = Bundle(for: QXBookReaderResources.self)
        if let path = bundle.path(forResource: "QXBookReaderResources.bundle", ofType: nil) {
            if let e = Bundle(path: path) {
                _bundle = e
                return e
            }
        }
        return Bundle()
    }
    private static var _bundle: Bundle?

    public init() { }
    
    public static func filePath(_ name: String) -> String {
        return bundle.path(forResource: name, ofType: nil)!
    }
    
    public static func image(_ cacheNamed: String) -> UIImage? {
        return UIImage(named: cacheNamed, in: bundle, compatibleWith: nil)
    }
}


