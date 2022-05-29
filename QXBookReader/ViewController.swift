//
//  ViewController.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/10.
//

import UIKit

class DemoBookView: UIButton {
    
    var respondTouchUpInside: (() -> Void)?
    
    public lazy var nameLabel: UILabel = {
        let e = UILabel()
        e.font = UIFont.systemFont(ofSize: 18)
        e.numberOfLines = 0
        e.textColor = UIColor.black
        e.textAlignment = .center
        return e
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(nameLabel)
        addTarget(self, action: #selector(click), for: .touchUpInside)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = bounds
    }
    
    @objc public func click() {
        respondTouchUpInside?()
    }
}

class ViewController: UIViewController {
    
    public lazy var bookView: DemoBookView = {
        let e = DemoBookView()
        e.nameLabel.text = "求魔"
        e.backgroundColor = UIColor.red
        weak var ws = self
        e.respondTouchUpInside = { [weak self, weak e] in
            if let s = self, let e = e {
                s.readBook("求魔.txt", coverView: e)
            }
        }
        return e
    }()
    public lazy var bookView1: DemoBookView = {
        let e = DemoBookView()
        e.nameLabel.text = "Functional Swift"
        e.backgroundColor = UIColor.red
        weak var ws = self
        e.respondTouchUpInside = { [weak self, weak e] in
            if let s = self, let e = e {
                s.readBook("Functional Swift.epub", coverView: e)
            }
        }
        return e
    }()
    public lazy var bookView2: DemoBookView = {
        let e = DemoBookView()
        e.nameLabel.text = "The Adventures Of Sherlock Holmes - Adventure I"
        e.backgroundColor = UIColor.red
        weak var ws = self
        e.respondTouchUpInside = { [weak self, weak e] in
            if let s = self, let e = e {
                s.readBook("The Adventures Of Sherlock Holmes - Adventure I.epub", coverView: e)
            }
        }
        return e
    }()
    
    public lazy var bookView3: DemoBookView = {
        let e = DemoBookView()
        e.nameLabel.text = "冰与火之歌1-5卷"
        e.backgroundColor = UIColor.red
        weak var ws = self
        e.respondTouchUpInside = { [weak self, weak e] in
            if let s = self, let e = e {
                s.readBook("冰与火之歌1-5卷.epub", coverView: e)
            }
        }
        return e
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        view.addSubview(bookView)
        view.addSubview(bookView1)
        view.addSubview(bookView2)
        view.addSubview(bookView3)

//        QXBookReaderConfigs.userRecordsPath = "/Users/labi3285/Desktop/books"
//        QXBookReaderConfigs.cachePath = "/Users/labi3285/Desktop/books"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bookView.frame = CGRect(x: 20, y: 50, width: 150, height: 200)
        bookView1.frame = CGRect(x: 20 + 150 + 20, y: 50, width: 150, height: 200)
        bookView2.frame = CGRect(x: 20, y: 50 + 20 + 200, width: 150, height: 200)
        bookView3.frame = CGRect(x: 20 + 150 + 20, y: 50 + 20 + 200, width: 150, height: 200)
    }
    
    func readBook(_ name: String, coverView: UIView?) {
        let path = Bundle.main.path(forResource: "TestBooks.bundle", ofType: nil)!
        let bundle = Bundle(path: path)!
//        let cachePath = "/Users/labi3285/Desktop/books"
                
        let bookPath = bundle.path(forResource: name, ofType: nil)!
//        let pageViewSize = UIScreen.main.bounds.size
//        let options = QXBookOptions(pageViewSize: pageViewSize, cachePath: cachePath)
//        print("start")
//        let r = QXBookParser.parseBookTxt(bookPath, options: options)
//        print(r)
//        print("end")
        
        let vc = QXBookReaderVc()
        vc.filePath = bookPath
        vc.bringInBookView = coverView
        present(vc, animated: true, completion: nil)
    }

}

