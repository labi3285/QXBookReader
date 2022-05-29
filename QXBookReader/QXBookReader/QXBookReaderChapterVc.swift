//
//  QXBookReaderChapterVc.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/19.
//

import UIKit

public enum QXBookReaderChapterLocation {
    case start
    case end
    case page(Int)
    case tag(String)
    case nodeIndexPath(String)
}

open class QXBookReaderChapterVc: UIViewController {
    
    public weak var interactionDelegate: QXBookReaderWebViewInteractionDelegate?

    public var respondChapterPagesLoaded: (() -> Void)?
    
    public var pageMode: QXBookReaderPageMode!
    public var theme: QXBookReaderTheme!
    public var options: QXBookOptions!
    public var book: QXBook!
    public var chapter: QXBookChapter!
    
    public func setup() {
        view.backgroundColor = theme.backgroundColor
        loadStatusView.theme = theme
        webView.pageMode = pageMode
        webView.book = book
        webView.chapter = chapter
        webView.theme = theme
        webView.options = options
        webView.setup()
    }
    
    public func update() {
        setup()
        webView.update()
    }
    
    public func getCurrentNodeIndexPath() -> (nodeIndexPath: String, content: String)? {
        return webView.getCurrentNodeIndexPath()
    }
    
    public var currentPageIndex: Int? {
        return webView.pageIndex
    }
    
    public func gotoLocation(_ location: QXBookReaderChapterLocation) {
        webView.gotoLocation(location)
    }
    
    public func getPageIndexInfo() -> (pageIndex: Int, total: Int) {
        return (webView.pageIndex, webView.pageCount)
    }
    
    public func loadData(initLocation: QXBookReaderChapterLocation) {        
        weak var ws = self
        loadStatusView.status = .loading("加载中")
        webView.loadData(location: initLocation) { err in
            if let err = err {
                ws?.loadStatusView.status = .error(err)
            } else {
                ws?.loadStatusView.status = .ok
            }
            ws?.respondChapterPagesLoaded?()
        }
    }
    
    public lazy var webView: QXBookReaderWebView = {
        let e = QXBookReaderWebView()
        e.interactionDelegate = self
        e.baseVc = self
        return e
    }()
    public lazy var loadStatusView: QXBookReaderLoadStatusView = {
        let e = QXBookReaderLoadStatusView()
        return e
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        view.addSubview(loadStatusView)
    }
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = CGRect(x: 0, y: QXBookReaderUtils.getStatusBarHeight(), width: view.bounds.width, height: view.bounds.height - QXBookReaderUtils.getStatusBarHeight() - QXBookReaderChaptersBottomView.height)
        loadStatusView.frame = view.bounds
    }
}

extension QXBookReaderChapterVc: QXBookReaderWebViewInteractionDelegate {
    
    public func webViewGetIsBarsShow(_ webView: QXBookReaderWebView) -> Bool {
        return interactionDelegate?.webViewGetIsBarsShow(webView) ?? false
    }
    
    public func webViewNeedJumpToIndex(_ webView: QXBookReaderWebView, index: QXBookIndex) {
        interactionDelegate?.webViewNeedJumpToIndex(webView, index: index)
    }
    
    public func webViewSetIsBarsShow(_ webView: QXBookReaderWebView, isBarsShow: Bool) {
        interactionDelegate?.webViewSetIsBarsShow(webView, isBarsShow: isBarsShow)
    }
    
    public func webViewNeedGoToPrevChapter(_ webView: QXBookReaderWebView) {
        interactionDelegate?.webViewNeedGoToPrevChapter(webView)
    }
    
    public func webViewNeedGoToNextChapter(_ webView: QXBookReaderWebView) {
        interactionDelegate?.webViewNeedGoToNextChapter(webView)
    }
    
    public func webViewDidChangePage(_ webView: QXBookReaderWebView, pageIndex: Int) {
        interactionDelegate?.webViewDidChangePage(webView, pageIndex: pageIndex)
    }
}
