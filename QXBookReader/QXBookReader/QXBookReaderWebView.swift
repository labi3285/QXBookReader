//
//  QXBookReaderWebView.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/16.
//

import UIKit
import JavaScriptCore
import SafariServices

public protocol QXBookReaderWebViewInteractionDelegate: AnyObject {
    
    func webViewGetIsBarsShow(_ webView: QXBookReaderWebView) -> Bool
    func webViewSetIsBarsShow(_ webView: QXBookReaderWebView, isBarsShow: Bool)
    
    func webViewNeedGoToPrevChapter(_ webView: QXBookReaderWebView)
    func webViewNeedGoToNextChapter(_ webView: QXBookReaderWebView)
    
    func webViewDidChangePage(_ webView: QXBookReaderWebView, pageIndex: Int)
    
    
    func webViewNeedJumpToIndex(_ webView: QXBookReaderWebView, index: QXBookIndex)

}

open class QXBookReaderWebView: UIWebView {
    
    public weak var baseVc: UIViewController?
    public var book: QXBook!
    public var chapter: QXBookChapter!
    
    public var pageMode: QXBookReaderPageMode!
    public var theme: QXBookReaderTheme!
    public var options: QXBookOptions!
    
    public weak var interactionDelegate: QXBookReaderWebViewInteractionDelegate?
    
    public func getCurrentNodeIndexPath() -> (nodeIndexPath: String, content: String)? {
        let offset = scrollView.bounds.height * CGFloat(pageIndex)
        guard let json = stringByEvaluatingJavaScript(from: "__qx_book_get_first_showing_element_index_path_info('\(offset)');") else {
            return nil
        }
        guard let dic = QXBookUtils.jsonStringToDictionary(json) else { return nil }
        guard let indexPath = dic["indexPath"] as? String else { return nil }
        guard let content = dic["content"] as? String else { return nil }
        return (indexPath, content)
    }
    
    public func setup() {
        switch pageMode! {
        case .page:
            scrollView.contentOffset = CGPoint.zero
            scrollView.bounces = false
            paginationBreakingMode = .page
            paginationMode = .leftToRight
            scrollView.isPagingEnabled = true
            _bottomCoverView.isHidden = false
        case .scroll:
            scrollView.contentOffset = CGPoint.zero
            scrollView.bounces = true
            paginationBreakingMode = .column
            paginationMode = .unpaginated
            scrollView.isPagingEnabled = false
            _bottomCoverView.isHidden = true
        }
        backgroundColor = theme.backgroundColor
        _bottomCoverView.backgroundColor = theme.backgroundColor
    }
    
    public func update() {
        setup()
        stringByEvaluatingJavaScript(from: "__qx_book_set_font_size('__qx_book_font_size_\(options.textFontSize)');")
        stringByEvaluatingJavaScript(from: "__qx_book_set_theme('__qx_book_theme_\(theme.code)');")
        let lineHeightRate = "\(options.lineHeightRate)".replacingOccurrences(of: ".", with: "_")
        stringByEvaluatingJavaScript(from: "__qx_book_set_line_space_rate('__qx_book_line_space_rate_\(lineHeightRate)');")
        _updateCoverViewFrame()
    }
    
    public func gotoLocation(_ location: QXBookReaderChapterLocation) {
        _location = location
        switch location {
        case .start:
            scrollView.contentOffset = CGPoint.zero
        case .end:
            switch pageMode! {
            case .page:
                scrollView.contentOffset = CGPoint(x: scrollView.contentSize.width - scrollView.bounds.width, y: 0)
            case .scroll:
                scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height)
            }
        case .page(let i):
            switch pageMode! {
            case .page:
                scrollView.contentOffset = CGPoint(x: scrollView.bounds.width * CGFloat(i), y: 0)
            case .scroll:
                scrollView.contentOffset = CGPoint(x: 0, y: scrollView.bounds.height * CGFloat(i))
            }
        case .nodeIndexPath(let nodeIndexPath):
            gotoElementWithNodeIndexPath(nodeIndexPath)
        case .tag(let id):
            gotoElementWithId(id)
        }
    }
    public func gotoElementWithNodeIndexPath(_ nodeIndexPath: String) {
        guard let res = stringByEvaluatingJavaScript(from: "__qx_book_get_element_offset_by_index_path('\(nodeIndexPath)','\(pageMode.rawValue)')") else {
            return
        }
        let offset = CGFloat((res as NSString).floatValue)
        switch pageMode! {
        case .page:
            scrollView.contentOffset = CGPoint(x: offset, y: 0)
        case .scroll:
            scrollView.contentOffset = CGPoint(x: 0, y: offset)
        }
    }
    public func gotoElementWithId(_ id: String) {
        guard let res = stringByEvaluatingJavaScript(from: "__qx_book_get_element_offset_by_id('\(id)','\(pageMode.rawValue)')") else {
            return
        }
        let offset = CGFloat((res as NSString).floatValue)
        switch pageMode! {
        case .page:
            scrollView.contentOffset = CGPoint(x: offset, y: 0)
        case .scroll:
            scrollView.contentOffset = CGPoint(x: 0, y: offset)
        }
    }
    public func gotoPrevPage() -> Bool {
        var offset = scrollView.contentOffset.x
        let w = scrollView.bounds.width
        offset -= w
        if offset >= 0 {
            alpha = 0
            scrollView.contentOffset = CGPoint(x: offset, y: 0)
            interactionDelegate?.webViewDidChangePage(self, pageIndex: self.pageIndex)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 / 25) {
                self.alpha = 1
            }
            return true
        }
        return false
    }
    public func gotoNextPage() -> Bool {
        var offset = scrollView.contentOffset.x
        let w = scrollView.bounds.width
        offset += w
        if offset <= scrollView.contentSize.width - w {
            alpha = 0
            scrollView.contentOffset = CGPoint(x: offset, y: 0)
            interactionDelegate?.webViewDidChangePage(self, pageIndex: self.pageIndex)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 / 25) {
                self.alpha = 1
            }
            return true
        }
        return false
    }
    public func gotoPageIndex(_ pageIndex: Int) {
        let _lastPageIndex = pageIndex
        if pageIndex != _lastPageIndex {
            alpha = 0
            let offset = CGFloat(pageIndex) * scrollView.bounds.width
            scrollView.contentOffset = CGPoint(x: offset, y: 0)
            interactionDelegate?.webViewDidChangePage(self, pageIndex: self.pageIndex)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 / 25) {
                self.alpha = 1
            }
        }
    }
    
    open override var pageCount: Int {
        switch pageMode! {
        case .page:
            return super.pageCount
        case .scroll:
            if scrollView.bounds.height > 0 {
                return Int(ceil(scrollView.contentSize.height / scrollView.bounds.height))
            }
            return 0
        }
    }
    
    public var pageIndex: Int {
        switch pageMode! {
        case .page:
            if scrollView.bounds.width <= 0 {
                return 0
            }
            var i = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
            i = max(0, i)
            i = min(i, pageCount - 1)
            return i
        case .scroll:
            if scrollView.bounds.height <= 0 {
                return 0
            }
            var i = Int(round(scrollView.contentOffset.y / scrollView.bounds.height))
            i = max(0, i)
            i = min(i, pageCount - 1)
            if i == pageCount - 2 {
                if abs(scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.bounds.height)) < 100 {
                    i = pageCount - 1
                }
            }
            return i
        }
    }
    
    @objc func onTap(_ tap: UITapGestureRecognizer) {
        guard let d = interactionDelegate else {
            return
        }
        let isBarsShow = d.webViewGetIsBarsShow(self)
        if isBarsShow {
            d.webViewSetIsBarsShow(self, isBarsShow: false)
            return
        }
        let selectedText = stringByEvaluatingJavaScript(from: "__qx_book_get_selected_text()")
        if let t = selectedText, t.count > 0 {
            return
        }
        
        guard let v = tap.view else {
            return
        }
        let x = tap.location(in: v).x
        if x < v.bounds.width / 3 {
            switch pageMode! {
            case .scroll:
                return
            case .page:
                break
            }
            if !gotoPrevPage() {
                d.webViewNeedGoToPrevChapter(self)
            }
        } else if x > v.bounds.width * 2 / 3 {
            switch pageMode! {
            case .scroll:
                return
            case .page:
                break
            }
            if !gotoNextPage() {
                d.webViewNeedGoToNextChapter(self)
            }
        } else {
            d.webViewSetIsBarsShow(self, isBarsShow: true)
        }
    }
    
    open func loadData(location: QXBookReaderChapterLocation, done: @escaping (_ err: String?) -> Void) {
        _location = location
        _doneHandler = done
        var _html = ""
        let filePath: String
        switch chapter.reference {
        case .txt(let subPath):
            filePath = "\(options.cachePath)/\(book.bookName).\(book.bookType.rawValue).cache/\(subPath)"
            guard let text = try? String(contentsOfFile: filePath) else {
                done("解析失败")
                return
            }
            _html += "<?xml version='1.0' encoding='utf-8'?>"
            _html += "\n<html>"
            _html += "\n<head></head>"
            _html += "\n<body>"
            _html += "\n<h1 style='font-size: 30px; text-align: center;'>"
            _html += "\n\(chapter.title)"
            _html += "\n</h1>"
            for t in text.components(separatedBy: "\n　　") {
                _html += "\n<p style='text-indent: 1.5em;'>"
                _html += "\n\(t)"
                _html += "\n</p>"
            }
            _html += "\n</body>"
            _html += "\n</html>"
            _html += "\n"
        case .resource(let resource):
            filePath = "\(options.cachePath)/\(book.bookName).\(book.bookType.rawValue).cache/\(resource.subPath)"
            let url = URL(fileURLWithPath: filePath)
            guard let html = try? String(contentsOf: url) else {
                done("解析失败")
                return
            }
            _html = html
        }
        
        var _js = "\n"
        _js += "<script type='text/javascript' src='\(QXBookReaderResources.filePath("webview_bridge.js"))'></script>\n"
        _html = _html.replacingOccurrences(of: "</head>", with: "\(_js)</head>")

        var _css = "\n"
        _css += "<link rel='stylesheet' type='text/css' href='\(QXBookReaderResources.filePath("webview_common_styles.css"))'>\n"
        switch chapter.reference {
        case .txt(_):
            _css += "<link rel='stylesheet' type='text/css' href='\(QXBookReaderResources.filePath("webview_txt_styles.css"))'>\n"
        case .resource(_):
            _css += "<link rel='stylesheet' type='text/css' href='\(QXBookReaderResources.filePath("webview_epub_styles.css"))'>\n"
        }
        _html = _html.replacingOccurrences(of: "</head>", with: "\(_css)</head>")
        
        var _cls = ""
        _cls += "__qx_book_font_size_\(options.textFontSize) "
        _cls += "__qx_book_line_space_rate_\("\(options.lineHeightRate)".replacingOccurrences(of: ".", with: "_")) "
        _cls += "__qx_book_theme_\(theme.code) "
                
        _html = _html.replacingOccurrences(of: "<head", with: "<html class='\(_cls)'")
        
        let baseUrl = URL(fileURLWithPath: (filePath as NSString).deletingLastPathComponent)
        alpha = 0
        loadHTMLString(_html, baseURL: baseUrl)
    }
    
    private lazy var _bottomCoverView: UIView = CoverView()
    private class CoverView: UIView {
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            return nil
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        scalesPageToFit = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 1
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        scrollView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        addGestureRecognizer(tap)
        scrollView.addSubview(_bottomCoverView)
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var _doneHandler: ((_ err: String?) -> Void)?
    var _location: QXBookReaderChapterLocation!
        
    private func _updateCoverViewFrame() {
        if pageMode == .scroll {
            return
        }
        if let contentHeight = stringByEvaluatingJavaScript(from: "document.documentElement.offsetHeight") {
            let totalH = frame.height * CGFloat(pageCount)
            let winH = scrollView.frame.height
            let winW = scrollView.frame.width
            let contentH = CGFloat(Double(contentHeight) ?? 0)
            let bottomH = totalH - contentH
            _bottomCoverView.frame = CGRect(x: winW * CGFloat(pageCount - 1), y: winH - bottomH - 1, width: winW, height: bottomH + 1)
        }
    }
}

extension QXBookReaderWebView: UIWebViewDelegate {
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        guard let url = request.url, let scheme = url.scheme else {
            return true
        }
        if scheme == "qxbookhighlight" {
            guard let decoded = url.absoluteString.removingPercentEncoding else { return false }
            let index = decoded.index(decoded.startIndex, offsetBy: 12)
            let rect = NSCoder.cgRect(for: String(decoded[index...]))
            _setupMenu(.handleHighlight)
            showMenu(rect)
            return false
        } else if scheme == "qxbookaudio" {
            return false
        } else if scheme == "file" {
            let tag = url.fragment
            if url.pathExtension.count > 0 {
                var resourceBasePath = "\(QXBookReaderConfigs.cachePath)/\(book.bookName).\(book.bookType.rawValue).cache"
                if let f = book.resourceBaseFolder {
                    resourceBasePath += "/\(f)"
                }
                let pathComps = url.path.components(separatedBy: resourceBasePath)
                if (pathComps.count <= 1 || pathComps[1].count == 0) {
                    return true
                }
                let href = pathComps[1].trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                var chapter: QXBookChapter?
                for e in book.chapters {
                    switch e.reference {
                    case .txt(_):
                        continue
                    case .resource(let r):
                        if r.subPath == href {
                            chapter = e
                            break
                        }
                    }
                }
                if let chapter = chapter {
                    let index = QXBookIndex(title: chapter.title, reference: chapter.reference)
                    index._tag = tag
                    interactionDelegate?.webViewNeedJumpToIndex(self, index: index)
                }
                return false
            } else {
                /// 页面级跳转
                if let tag = tag {
                    let index = QXBookIndex(title: chapter.title, reference: chapter.reference)
                    index._tag = tag
                    interactionDelegate?.webViewNeedJumpToIndex(self, index: index)                    
                    return false
                /// 页面加载
                } else {
                    return true
                }
            }
        } else if scheme == "mail" {
            return true
        } else if url.absoluteString != "about:blank" && scheme.contains("http") && navigationType == .linkClicked {
            if #available(iOS 9.0, *) {
                let vc = SFSafariViewController(url: url)
                vc.view.tintColor = QXBookReaderConfigs.tintColor
                baseVc?.present(vc, animated: true, completion: nil)
            } else {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            }
            return false
        } else {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
                return false
            }
        }
        return true
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        weak var ws = self
        scrollView.contentOffset = CGPoint.zero
        stringByEvaluatingJavaScript(from: "__qx_book_init_html()")
        _updateCoverViewFrame()
        gotoLocation(_location)
        alpha = 1
        _setupMenu(.handleText)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            if let s = ws {
                s.interactionDelegate?.webViewDidChangePage(s, pageIndex: s.pageIndex)
                s._doneHandler?(nil)
            }
        }
    }
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        _doneHandler?(error.localizedDescription)
    }
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        interactionDelegate?.webViewDidChangePage(self, pageIndex: pageIndex)
    }
}

extension QXBookReaderWebView {
    
    private enum MenuType {
        case handleText
        case setHighlight
        case handleHighlight
    }
    
    private func _setupMenu(_ menuType: MenuType) {
        switch menuType {
        case .handleText:
            UIMenuController.shared.menuItems = [
                UIMenuItem(title: "复制", action: #selector(actionCopy(_:))),
                UIMenuItem(title: "翻译", action: #selector(actionDefine(_:))),
//                UIMenuItem(title: "札记", action: #selector(actionSetHighlight(_:)))
            ]
        case .setHighlight:
            UIMenuController.shared.menuItems = [
                UIMenuItem(title: "黄", action: #selector(actionSetHighlightYellow(_:))),
                UIMenuItem(title: "绿", action: #selector(actionSetHighlightGreen(_:))),
                UIMenuItem(title: "蓝", action: #selector(actionSetHighlightBlue(_:))),
                UIMenuItem(title: "粉", action: #selector(actionSetHighlightPink(_:))),
                UIMenuItem(title: "下划线", action: #selector(actionSetHighlightUnderline(_:))),
            ]
        case .handleHighlight:
            UIMenuController.shared.menuItems = [
                UIMenuItem(title: "查看", action: #selector(actionShowHighlightDetail(_:))),
                UIMenuItem(title: "删除", action: #selector(actionRemoveHighlight(_:))),
            ]
        }
    }
    public func showMenu(_ rect: CGRect) {
        UIMenuController.shared.setTargetRect(rect, in: self)
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    public func hideMenu() {
        _setupMenu(.handleText)
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(actionCopy(_:))
            || action == #selector(actionDefine(_:))
            || action == #selector(actionSetHighlight(_:))
            || action == #selector(actionSetHighlightYellow(_:))
            || action == #selector(actionSetHighlightGreen(_:))
            || action == #selector(actionSetHighlightBlue(_:))
            || action == #selector(actionSetHighlightPink(_:))
            || action == #selector(actionSetHighlightUnderline(_:))
            || action == #selector(actionShowHighlightDetail(_:))
            || action == #selector(actionRemoveHighlight(_:)) {
            return true
        }
        return false
    }
    
    @objc func actionCopy(_ sender: UIMenuController) {
        guard let selectedText = stringByEvaluatingJavaScript(from: "__qx_book_get_selected_text()") else {
            return
        }
        UIPasteboard.general.string = selectedText
    }
    @objc func actionDefine(_ sender: UIMenuController?) {
        guard let selectedText = stringByEvaluatingJavaScript(from: "__qx_book_get_selected_text()") else {
            return
        }
        hideMenu()
        let vc = UIReferenceLibraryViewController(term: selectedText)
        vc.view.tintColor = QXBookReaderConfigs.tintColor
        baseVc?.present(vc, animated: true, completion: nil)
    }
    @objc func actionSetHighlight(_ sender: UIMenuController) {
        guard let res = stringByEvaluatingJavaScript(from: "__qx_book_check_or_update_selection_for_highlight()") else {
            return
        }        
        let rect = NSCoder.cgRect(for: res)
        _setupMenu(.setHighlight)
        showMenu(rect)
    }

    @objc func actionSetHighlightYellow(_ sender: UIMenuController) {
        let id = _generateId()
        guard let json = stringByEvaluatingJavaScript(from: "__qx_book_set_selection_highlight('\(id)', '__qx_book_highlight_yellow');") else {
            return
        }
        guard let dic = QXBookUtils.jsonStringToDictionary(json) else { return }
        
        print(dic)

    }
    @objc func actionSetHighlightGreen(_ sender: UIMenuController) {
        let id = _generateId()
        stringByEvaluatingJavaScript(from: "__qx_book_set_selection_highlight('\(id)', '__qx_book_highlight_green');")
    }
    @objc func actionSetHighlightBlue(_ sender: UIMenuController) {
        let id = _generateId()
        stringByEvaluatingJavaScript(from: "__qx_book_set_selection_highlight('\(id)', '__qx_book_highlight_blue');")
    }
    @objc func actionSetHighlightPink(_ sender: UIMenuController) {
        let id = _generateId()
        stringByEvaluatingJavaScript(from: "__qx_book_set_selection_highlight('\(id)', '__qx_book_highlight_pink');")
    }
    @objc func actionSetHighlightUnderline(_ sender: UIMenuController) {
        let id = _generateId()
        stringByEvaluatingJavaScript(from: "__qx_book_set_selection_highlight('\(id)', '__qx_book_highlight_underline');")
    }
    @objc func actionShowHighlightDetail(_ sender: UIMenuController) {
        
    }
    @objc func actionRemoveHighlight(_ sender: UIMenuController) {
        
    }
    
    private func _generateId() -> String {
        var t = UUID().uuidString
        t = t.replacingOccurrences(of: "-", with: "")
        return t
    }

}

extension QXBookReaderWebView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view is UIWebView {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return false
            } else if otherGestureRecognizer is UISwipeGestureRecognizer {
                return false
            } else if otherGestureRecognizer is UILongPressGestureRecognizer {
                if UIMenuController.shared.isMenuVisible {
                    hideMenu()
                }
                return false
            }
            return true
        }
        return false
    }
    
}
