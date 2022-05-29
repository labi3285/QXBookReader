//
//  QXBookReaderChaptersVc1.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/19.
//

import UIKit

public protocol QXBookReaderChaptersVcInteractionDelegate: AnyObject {
    func chaptersVcGetIsBarsShow(_ chaptersVc: QXBookReaderChaptersVc) -> Bool
    func chaptersVcSetIsBarsShow(_ chaptersVc: QXBookReaderChaptersVc, isBarsShow: Bool)
}

public class QXBookReaderChaptersVc: UIViewController {
    
    public weak var interactionDelegate: QXBookReaderChaptersVcInteractionDelegate?
    
    public var pageMode: QXBookReaderPageMode!
    public var theme: QXBookReaderTheme!
    public var options: QXBookOptions!
    public var book: QXBook!
    
    public var respondChapterPagesLoaded: (() -> Void)?
    
    public var chapters: [QXBookChapter] {
        return book?.chapters ?? []
    }
    
    public func getCurrentNodeIndexPath() -> (nodeIndexPath: String, content: String)? {
        return _getCurrentChapterVc()?.getCurrentNodeIndexPath()
    }
    public var currentChapter: QXBookChapter? {
        return _getCurrentChapterVc()?.chapter
    }
    public var currentChapterIndex: Int? {
        if let e = currentChapter {
            return chapters.firstIndex(where: { $0 == e })
        }
        return nil
    }
    public var currentChapterPageIndex: Int? {
        return _getCurrentChapterVc()?.currentPageIndex
    }
    
    public func gotoChapter(_ chapter: QXBookChapter, location: QXBookReaderChapterLocation) {
        guard let currentChapter = self.currentChapter else {
            return
        }
        if currentChapter == chapter {
            _getCurrentChapterVc()?.gotoLocation(location)
            return
        }
        if let chapter = book.chapters.first(where: { $0 == chapter }) {
            let vc = _generateChapterVc(chapter, initLocation: location)
            pageVc?.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        }
    }
    public func gotoPageMark(_ pageMark: QXBookPageMark) {
        let chapter = chapters[pageMark.chapterIndex]
        gotoChapter(chapter, location: .nodeIndexPath(pageMark.nodeIndexPath))
    }
    
    public func getCurrentChapterPageIndexInfo() -> (pageIndex: Int, total: Int)? {
        if let c = _getCurrentChapterVc() {
            return c.getPageIndexInfo()
        }
        return nil
    }
    public func gotoCurrentChapterPageIndex(_ pageIndex: Int) {
        if let c = _getCurrentChapterVc() {
            c.gotoLocation(.page(pageIndex))
        }
    }
    
    public func setup() {
        if let e = chapters.first {
            let vc = _generateChapterVc(e, initLocation: .start)
            pageVc?.setViewControllers([vc], direction: .forward, animated: false) { c in
                //self.update()
            }
        }
    }
    
    public func update() {
        bottomView.theme = theme
        _checkOrSetupPageVc()
        if let vcs = pageVc?.viewControllers as? [QXBookReaderChapterVc] {
            for vc in vcs {
                vc.pageMode = pageMode
                vc.theme = theme
                vc.loadStatusView.theme = theme
                vc.update()
            }
        }
    }
    
    public private(set) var pageVc: UIPageViewController?
    private var _lastPageMode: QXBookReaderPageMode?
    private func _checkOrSetupPageVc() {
        if let a = _lastPageMode, let b = pageMode {
            if a == b {
                return
            }
        }
        let lastChapter = currentChapter
        let lastNodeIndexPath = getCurrentNodeIndexPath()
        
        if let v = pageVc {
            v.removeFromParent()
            v.view.removeFromSuperview()
        }
        let pageVc: UIPageViewController
        switch pageMode! {
        case .scroll:
            pageVc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
        case .page:
            pageVc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        }
        pageVc.edgesForExtendedLayout = UIRectEdge()
        pageVc.extendedLayoutIncludesOpaqueBars = true
        pageVc.dataSource = self
        pageVc.delegate = self
        self.pageVc = pageVc
        addChild(pageVc)
        view.addSubview(pageVc.view)
        pageVc.view.frame = view.bounds
        view.bringSubviewToFront(bottomView)
        if let lastChapter = lastChapter ?? chapters.first {
            if let lastNodeIndexPath = lastNodeIndexPath {
                let vc = _generateChapterVc(lastChapter, initLocation: .nodeIndexPath(lastNodeIndexPath.nodeIndexPath))
                pageVc.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
            } else {
                let vc = _generateChapterVc(lastChapter, initLocation: .start)
                pageVc.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
            }
        }
    }
    public lazy var bottomView: QXBookReaderChaptersBottomView = {
        let e = QXBookReaderChaptersBottomView()
        e.backButton.respondClick = { [weak self] in
            self?._onBottomBack()
        }
        return e
    }()
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(bottomView)
    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageVc?.view.frame = view.bounds
        bottomView.frame = CGRect(x: 0, y: view.bounds.height - QXBookReaderChaptersBottomView.height, width: view.bounds.width, height: QXBookReaderChaptersBottomView.height)
    }
        
    private var _lastPageMark: QXBookPageMark?
    private var _navigationIndexes: [QXBookIndex] = []
}

extension QXBookReaderChaptersVc: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private func _getCurrentChapterVc() -> QXBookReaderChapterVc? {
        return pageVc?.viewControllers?.first as? QXBookReaderChapterVc
    }
    private func _generateChapterVc(_ chapter: QXBookChapter, initLocation: QXBookReaderChapterLocation) -> QXBookReaderChapterVc {
        let vc = QXBookReaderChapterVc()
        vc.interactionDelegate = self
        vc.pageMode = pageMode
        vc.theme = theme
        vc.loadStatusView.theme = theme
        vc.book = book
        vc.options = options
        vc.respondChapterPagesLoaded = { [weak self] in
            self?.respondChapterPagesLoaded?()
        }
        vc.chapter = chapter
        vc.setup()
        vc.loadData(initLocation: initLocation)
        return vc
    }
    
    private func _updateBottomView() {
        if let c = _getCurrentChapterVc() {
            bottomView.backButton.title = "◀︎ 返回(\(_navigationIndexes.count))"
            bottomView.backButton.isHidden = _navigationIndexes.count == 0
            bottomView.titleLabel.isHidden = _navigationIndexes.count > 0
            bottomView.titleLabel.text = c.chapter.title
            if c.webView.pageCount > 0 {
                if c.webView.pageCount > 2 {
                    bottomView.progressLabel.text = "\(c.webView.pageIndex + 1)/\(c.webView.pageCount)"
                } else {
                    bottomView.progressLabel.text = ""
                }
            }
        }
    }
    private func _onBottomBack() {
        _navigationIndexes.removeLast()
        _updateBottomView()
        if let e = _navigationIndexes.last {
            if let tag = e.tag {
                gotoChapter(e.chapter, location: .tag(tag))
            } else {
                gotoChapter(e.chapter, location: .start)
            }
        } else {
            if let e = _lastPageMark {
                gotoPageMark(e)
            }
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let i = currentChapterIndex {
            if i > 0 {
                let chapter = chapters[i - 1]
                return _generateChapterVc(chapter, initLocation: .end)
            }
        }
        return nil
    }
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let i = currentChapterIndex {
            if i < chapters.count - 1 {
                let chapter = chapters[i + 1]
                return _generateChapterVc(chapter, initLocation: .start)
            }
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        _updateBottomView()
    }

}

extension QXBookReaderChaptersVc: QXBookReaderWebViewInteractionDelegate {
    public func webViewGetIsBarsShow(_ webView: QXBookReaderWebView) -> Bool {
        return interactionDelegate?.chaptersVcGetIsBarsShow(self) ?? false
    }
    public func webViewSetIsBarsShow(_ webView: QXBookReaderWebView, isBarsShow: Bool) {
        interactionDelegate?.chaptersVcSetIsBarsShow(self, isBarsShow: isBarsShow)
    }
    
    public func webViewNeedJumpToIndex(_ webView: QXBookReaderWebView, index: QXBookIndex) {
        if _navigationIndexes.count == 0 {
            if let i = currentChapterIndex, let nodeIndexPath = webView.getCurrentNodeIndexPath() {
                let pageMark = QXBookPageMark(chapterIndex: i, nodeIndexPath: nodeIndexPath.nodeIndexPath)
                _lastPageMark = pageMark
            }
        }
        _navigationIndexes.append(index)
        if let tag = index.tag {
            gotoChapter(index.chapter, location: .tag(tag))
        } else {
            gotoChapter(index.chapter, location: .start)
        }
    }
    
    public func webViewNeedGoToPrevChapter(_ webView: QXBookReaderWebView) {
        if let i = currentChapterIndex, i > 0 {
            gotoChapter(book.chapters[i - 1], location: .end)
        }
    }
    public func webViewNeedGoToNextChapter(_ webView: QXBookReaderWebView) {
        if let i = currentChapterIndex, i < chapters.count - 1 {
            gotoChapter(book.chapters[i + 1], location: .start)
        }
    }
    
    public func webViewDidChangePage(_ webView: QXBookReaderWebView, pageIndex: Int) {
        _updateBottomView()
        interactionDelegate?.chaptersVcSetIsBarsShow(self, isBarsShow: false)
    }
    
}


public class QXBookReaderChaptersBottomView: UIView {
    
    public var theme: QXBookReaderTheme! {
        didSet {
            titleLabel.textColor = theme.textColor
            progressLabel.textColor = theme.textColor
            backgroundColor = theme.backgroundColor
            backButton.myTitleLabel.textColor = theme.textColor
        }
    }
    
    public static let height: CGFloat = QXBookReaderUtils.getBottomAppendHeight() + 30
    
    public lazy var backButton: QXBookReaderTitleButton = {
        let e = QXBookReaderTitleButton()
        e.myTitleLabel.font = UIFont.systemFont(ofSize: 9)
        e.myTitleLabel.textAlignment = .left
        return e
    }()
    public lazy var titleLabel: UILabel = {
        let e = UILabel()
        e.font = UIFont.systemFont(ofSize: 9)
        return e
    }()
    public lazy var progressLabel: UILabel = {
        let e = UILabel()
        e.font = UIFont.systemFont(ofSize: 9)
        e.textAlignment = .right
        return e
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(backButton)
        addSubview(progressLabel)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 15, y: 0, width: bounds.width - 15 - 60, height: 30)
        backButton.frame = CGRect(x: 15, y: 0, width: 100, height: 30)
        progressLabel.frame = CGRect(x: bounds.width - 15 - 60, y: 0, width: 60, height: 30)
    }
    
}
