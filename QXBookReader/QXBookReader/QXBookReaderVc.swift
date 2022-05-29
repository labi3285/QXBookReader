//
//  QXBookReaderVc.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/10.
//

import UIKit
import QXMessageView
import SSZipArchive

public class QXBookReaderVc: UIViewController {
    
    public var filePath: String?
    public var bringInBookView: UIView?
    
        
    public private(set) var book: QXBook?
    public private(set) var pageMode: QXBookReaderPageMode?
    public private(set) var options: QXBookOptions?
    public private(set) var theme: QXBookReaderTheme = QXBookReaderTheme.themes[0]

    public private(set) var pageMarks: [QXBookPageMark]?

    public lazy var topBarView: QXBookReaderTopBarView = {
        let e = QXBookReaderTopBarView()
        e.isHidden = true
        e.delegate = self
        return e
    }()
    public lazy var bottomBarView: QXBookReaderBottomBarView = {
        let e = QXBookReaderBottomBarView()
        e.isHidden = true
        e.delegate = self
        return e
    }()
    
    public lazy var loadStatusView: QXBookReaderLoadStatusView = {
        let e = QXBookReaderLoadStatusView()
        return e
    }()
    public lazy var chaptersVc: QXBookReaderChaptersVc = {
        let e = QXBookReaderChaptersVc()
        e.interactionDelegate = self
        e.respondChapterPagesLoaded = { [weak self] in
            self?.topBarView.update()
            self?.bottomBarView.update()
        }
        return e
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(chaptersVc.view)
        addChild(chaptersVc)
        view.addSubview(loadStatusView)
        view.addSubview(bottomBarView)
        view.addSubview(topBarView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(tap)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loadData()
        }
    }
    
    public private(set) var isBarViewsShow: Bool = true {
        didSet {
            topBarView.isHidden = !isBarViewsShow
            bottomBarView.isHidden = !isBarViewsShow
        }
    }
    
    @objc public func onTap(_ tap: UITapGestureRecognizer) {
        isBarViewsShow = !isBarViewsShow
    }

    open func loadData() {
        weak var ws = self
        guard let filePath = filePath else {
            loadStatusView.status = .error("路径为空")
            return
        }
        loadStatusView.status = .loading("加载中...")
        let _cachePath = QXBookReaderConfigs.cachePath
        let _options = QXBookOptions(cachePath: _cachePath)
        if let code = QXBookReaderUtils.getStringValueFromUserDefaults("QXBookUserSetting_themeCode") {
            if let e = QXBookReaderTheme.themes.first(where: { $0.code == code }) {
                self.theme = e
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
        _options.titleColor = theme.titleColor
        _options.textColor = theme.textColor
        _options.linkColor = theme.linkColor
        if let e = QXBookReaderUtils.getStringValueFromUserDefaults("QXBookUserSetting_fontName") {
            _options.titleFontName = e
            _options.textFontName = e
        }
        if let e = QXBookReaderUtils.getIntValueFromUserDefaults("QXBookUserSetting_fontSize") {
            _options.titleFontSize = Int(CGFloat(e) * 1.5)
            _options.textFontSize = e
        }
        if let e = QXBookReaderUtils.getCGFloatValueFromUserDefaults("QXBookUserSetting_lineHeightRate") {
            _options.lineHeightRate = e
        }
        let _pageMode: QXBookReaderPageMode
        if let e = QXBookReaderUtils.getStringValueFromUserDefaults("QXBookUserSetting_pageMode") {
            _pageMode = QXBookReaderPageMode(rawValue: e) ?? .page
        } else {
            _pageMode = .page
        }
        self.options = _options
        self.pageMode = _pageMode
        chaptersVc.pageMode = _pageMode
        chaptersVc.options = _options
        chaptersVc.theme = theme
        chaptersVc.update()
        view.backgroundColor = theme.backgroundColor
        loadStatusView.theme = theme
                
        DispatchQueue(label: "QXBookReaderParserQueue").async {
            let result = QXBookParser.parseBook(filePath, options: _options)
            DispatchQueue.main.async {
                switch result {
                case .ok(let book):
                    ws?.book = book
                    ws?.chaptersVc.book = book
                    ws?.chaptersVc.setup()
                    ws?.topBarView.update()
                    ws?.bottomBarView.update()
                    ws?.loadStatusView.status = .ok
                case .error(let err):
                    ws?.loadStatusView.status = .error(err.message)
                }
            }
        }
    }
    
    public required init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
        view.backgroundColor = UIColor.white
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 3, height: 0)
        view.layer.shadowRadius = 3
        view.layer.shadowColor = UIColor.black.cgColor
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        chaptersVc.view.frame = view.bounds
        loadStatusView.frame = view.bounds
        topBarView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topBarView.height)
        bottomBarView.frame = CGRect(x: 0, y: view.bounds.height - bottomBarView.height, width: view.bounds.width, height: bottomBarView.height)
    }
    
    private var _isPresent = true
    private var _presentDuration: TimeInterval = 1
    private var _dismissDuration: TimeInterval = 0.5
    public lazy var _bookCoverView: UIImageView = {
        let e = UIImageView()
        e.contentMode = .scaleToFill
        e.clipsToBounds = true
        e.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        return e
    }()
    private func _originBookRect(containerView: UIView) -> CGRect? {
        if let v = bringInBookView {
            _bookCoverView.backgroundColor = v.backgroundColor
            _bookCoverView.image = QXBookReaderUtils.screenShot(v)
            let rect = v.convert(v.bounds, to: containerView)
            return rect
        }
        return nil
    }
        
}

extension QXBookReaderVc: QXBookReaderChaptersVcInteractionDelegate {
    
    public func chaptersVcGetIsBarsShow(_ chaptersVc: QXBookReaderChaptersVc) -> Bool {
        return isBarViewsShow
    }
    public func chaptersVcSetIsBarsShow(_ chaptersVc: QXBookReaderChaptersVc, isBarsShow: Bool) {
        if isBarsShow {
            topBarView.update()
            bottomBarView.update()
        }
        self.isBarViewsShow = isBarsShow
    }
    
}

extension QXBookReaderVc: QXBookReaderTopBarViewDelegate, QXBookReaderBottomBarViewDelegate, QXBookReaderSettingsVcDelegate {

    public func topBarViewCloseBook(_ barView: QXBookReaderTopBarView) {
        dismiss(animated: true, completion: nil)
    }
    public func topBarViewGetTitle(_ barView: QXBookReaderTopBarView) -> String {
        return book?.title ?? book?.bookName ?? ""
    }

    public func topBarViewGetIsPageMarked(_ barView: QXBookReaderTopBarView, done: (Bool) -> Void) {
        if let book = book, let chapterIndex = chaptersVc.currentChapterIndex, let nodeIndexPathInfo = chaptersVc.getCurrentNodeIndexPath()  {
            if pageMarks == nil {
                let folder = "\(QXBookReaderConfigs.userRecordsPath)/\(book.bookName).\(book.bookType.rawValue).records"
                let filePath = "\(folder)/marks.json"
                if let json = try? String(contentsOfFile: filePath), let arr = QXBookUtils.jsonStringToArray(json) {
                    pageMarks = arr.compactMap({ QXBookPageMark.fromDictionary($0) })
                } else {
                    pageMarks = []
                }
            }
            var _find = false
            for e in pageMarks ?? [] {
                if e.chapterIndex == chapterIndex && e.nodeIndexPath == nodeIndexPathInfo.nodeIndexPath {
                    _find = true
                    break
                }
            }
            done(_find)
        } else {
            done(false)
        }
    }
    
    public func topBarViewMarkPage(_ barView: QXBookReaderTopBarView, isMark: Bool, done: (Bool) -> Void) {
        if var pageMarks = pageMarks, let book = book, let chapter = chaptersVc.currentChapter, let chapterIndex = chaptersVc.currentChapterIndex, let nodeIndexPathInfo = chaptersVc.getCurrentNodeIndexPath() {
            let mark = QXBookPageMark(chapterIndex: chapterIndex, nodeIndexPath: nodeIndexPathInfo.nodeIndexPath)
            mark.createTime = Date().timeIntervalSince1970
            mark.chapterTitle = chapter.title
            mark.content = nodeIndexPathInfo.content
            pageMarks.insert(mark, at: 0)
            let folderPath = "\(QXBookReaderConfigs.userRecordsPath)/\(book.bookName).\(book.bookType.rawValue).records"
            let filePath = "\(folderPath)/marks.json"
            if let err = QXBookUtils.checkOrMakeFolder(folderPath) {
                QXMessageView.demoFailure(msg: err.localizedDescription, superview: view)
                done(false)
            } else {
                if let json = QXBookUtils.arrayToJsonString(pageMarks.map({ $0.toDictionary() })) {
                    if let err = QXBookUtils.saveToFile(json, filePath: filePath) {
                        QXMessageView.demoFailure(msg: err.localizedDescription, superview: view)
                        done(false)
                    } else {
                        // 触发刷新
                        self.pageMarks = nil
                        done(true)
                    }
                } else {
                    done(false)
                }
            }
        }
    }

    public func bottomBarViewShowIndex(_ barView: QXBookReaderBottomBarView) {
        if let ms = book?.indexes {
            weak var ws = self
            let vc = QXBookReaderIndexVc()
//            vc.bringInIndex = chaptersVc.currentChapter?.index
            vc.indexes = ms
            vc.pageMarks = pageMarks ?? []
            vc.respondSelectChapter = { m in
                if let t = m.tag {
                    ws?.chaptersVc.gotoChapter(m.chapter, location: .tag(t))
                } else {
                    ws?.chaptersVc.gotoChapter(m.chapter, location: .start)
                }
                ws?.isBarViewsShow = false
            }
            vc.respondSelectPageMark = { m in
                ws?.chaptersVc.gotoPageMark(m)
                ws?.isBarViewsShow = false
            }
            present(vc, animated: true, completion: nil)
        }
    }
    
    public func bottomBarViewGetChapterPageIndexInfo(_ barView: QXBookReaderBottomBarView) -> (pageIndex: Int, total: Int) {
        return chaptersVc.getCurrentChapterPageIndexInfo() ?? (0, 0)
    }
    public func bottomBarViewGoToChapterPageIndex(_ barView: QXBookReaderBottomBarView, pageIndex: Int) {
        chaptersVc.gotoCurrentChapterPageIndex(pageIndex)
    }

    public func bottomBarViewShowSettings(_ barView: QXBookReaderBottomBarView) {
        let vc = QXBookReaderSettingsVc()
        vc.delegate = self
        vc.update()
        present(vc, animated: true, completion: nil)
    }
    
    public func bottomBarViewCanPrevChapter(_ barView: QXBookReaderBottomBarView) -> Bool {
        if let e = chaptersVc.currentChapter {
            if let i = chaptersVc.chapters.firstIndex(where: { $0 == e }) {
                return i > 0
            }
        }
        return false
    }
    public func bottomBarViewCanNextChapter(_ barView: QXBookReaderBottomBarView) -> Bool {
        if let e = chaptersVc.currentChapter {
            if let i = chaptersVc.chapters.firstIndex(where: { $0 == e }) {
                return i < chaptersVc.chapters.count - 1
            }
        }
        return false
    }
    public func bottomBarViewGoPrevChapter(_ barView: QXBookReaderBottomBarView) {
        if let e = chaptersVc.currentChapter {
            if let i = chaptersVc.chapters.firstIndex(where: { $0 == e }) {
                chaptersVc.gotoChapter(chaptersVc.chapters[i - 1], location: .start)
            }
        }
    }
    public func bottomBarViewGoNextChapter(_ barView: QXBookReaderBottomBarView) {
        if let e = chaptersVc.currentChapter {
            if let i = chaptersVc.chapters.firstIndex(where: { $0 == e }) {
                chaptersVc.gotoChapter(chaptersVc.chapters[i + 1], location: .start)
            }
        }
    }
    
    public func settingsVcGetBrightness(_ settingsVc: QXBookReaderSettingsVc) -> Double {
        return Double(UIScreen.main.brightness)
    }
    public func settingsVcSetBrightness(_ settingsVc: QXBookReaderSettingsVc, brightness: Double) {
        UIScreen.main.brightness = CGFloat(brightness)
    }
    
    public func settingsVcCanMinusFontSize(_ settingsVc: QXBookReaderSettingsVc) -> Bool {
        if let e = options {
            return e.textFontSize > 10
        }
        return false
    }
    public func settingsVcCanPlusFontSize(_ settingsVc: QXBookReaderSettingsVc) -> Bool {
        if let e = options {
            return e.textFontSize < 30
        }
        return false
    }
    public func settingsVcGetFontSize(_ settingsVc: QXBookReaderSettingsVc) -> Int {
        if let e = options {
            return Int(e.textFontSize)
        }
        return 16
    }
    public func settingsVcSetFontSize(_ settingsVc: QXBookReaderSettingsVc, fontSize: Int) {
        if let e = options {
            e.titleFontSize = Int(CGFloat(fontSize) * 1.5)
            e.textFontSize = fontSize
            chaptersVc.update()
            QXBookReaderUtils.setValueToUserDefaults(value: CGFloat(fontSize), key: "QXBookUserSetting_fontSize")
        }
    }
    
    public func settingsVcGetPageMode(_ settingsVc: QXBookReaderSettingsVc) -> QXBookReaderPageMode {
        return pageMode ??  .page
    }
    public func settingsVcSetPageMode(_ settingsVc: QXBookReaderSettingsVc, pageMode: QXBookReaderPageMode) {
        self.pageMode = pageMode
        chaptersVc.pageMode = pageMode
        chaptersVc.update()
        QXBookReaderUtils.setValueToUserDefaults(value: pageMode.rawValue, key: "QXBookUserSetting_pageMode")
    }

    public func settingsVcGetTheme(_ settingsVc: QXBookReaderSettingsVc) -> QXBookReaderTheme {
        return theme
    }
    public func settingsVcSetTheme(_ settingsVc: QXBookReaderSettingsVc, theme: QXBookReaderTheme) {
        if let e = options {
            e.titleColor = theme.titleColor
            e.textColor = theme.textColor
            e.linkColor = theme.linkColor
            chaptersVc.theme = theme
            chaptersVc.update()
            self.theme = theme
            QXBookReaderUtils.setValueToUserDefaults(value: theme.code, key: "QXBookUserSetting_themeCode")
        }
    }
    
    public func settingsVcGetLineHeightRate(_ settingsVc: QXBookReaderSettingsVc) -> CGFloat {
        if let e = options {
            return e.lineHeightRate
        }
        return 1
    }
    
    public func settingsVcSetLineHeightRate(_ settingsVc: QXBookReaderSettingsVc, rate: CGFloat) {
        if let e = options {
            e.lineHeightRate = rate
            chaptersVc.update()
            QXBookReaderUtils.setValueToUserDefaults(value: rate, key: "QXBookUserSetting_lineHeightRate")
        }
    }

}

extension QXBookReaderVc: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self._isPresent = true
        return self
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self._isPresent = false
        return self
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if _isPresent {
            return _presentDuration
        } else {
            return _dismissDuration
        }
    }
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromVc = transitionContext.viewController(forKey: .from)!
        let toVc = transitionContext.viewController(forKey: .to)!
        if _isPresent {
            containerView.addSubview(toVc.view)
            if let r = _originBookRect(containerView: containerView) {
                toVc.view.frame = containerView.bounds
                toVc.view.transform = QXBookReaderUtils.getCGAffineTransform(containerView.bounds, targetRect: r)
                containerView.addSubview(_bookCoverView)
                _bookCoverView.frame = r
                if #available(iOS 13.0, *) {
                    self._bookCoverView.transform3D = CATransform3DIdentity
                } else {
                    // Fallback on earlier versions
                }
                UIView.animate(withDuration: _presentDuration) {
                    self._bookCoverView.frame = containerView.bounds
                    let rotate = CATransform3DMakeRotation(CGFloat.pi / 2, 0, -1, 0)
                    var scale = CATransform3DIdentity
                    scale.m34 = -1 / (containerView.bounds.width * 4)
                    if #available(iOS 13.0, *) {
                        self._bookCoverView.transform3D = CATransform3DConcat(rotate, scale)
                    } else {
                        // Fallback on earlier versions
                    }
                    toVc.view.transform = CGAffineTransform.identity
                } completion: { c in
                    self._bookCoverView.removeFromSuperview()
                    transitionContext.completeTransition(c)
                }
            } else {
                toVc.view.frame = CGRect(x: 0, y: containerView.bounds.height, width: containerView.bounds.width, height: containerView.bounds.height)
                UIView.animate(withDuration: _presentDuration) {
                    toVc.view.frame = containerView.bounds
                } completion: { c in
                    transitionContext.completeTransition(c)
                }
            }
        } else {
            if let r = _originBookRect(containerView: containerView) {
                containerView.addSubview(_bookCoverView)
                UIView.animate(withDuration: _dismissDuration) {
                    self._bookCoverView.frame = r
                    if #available(iOS 13.0, *) {
                        self._bookCoverView.transform3D = CATransform3DIdentity
                    } else {
                        // Fallback on earlier versions
                    }
                    fromVc.view.transform = QXBookReaderUtils.getCGAffineTransform(containerView.bounds, targetRect: r)
                } completion: { c in
                    self._bookCoverView.removeFromSuperview()
                    fromVc.view.removeFromSuperview()
                    transitionContext.completeTransition(c)
                }
            } else {
                UIView.animate(withDuration: _dismissDuration) {
                    fromVc.view.frame = CGRect(x: 0, y: containerView.bounds.height, width: containerView.bounds.width, height: containerView.bounds.height)
                } completion: { c in
                    fromVc.view.removeFromSuperview()
                    transitionContext.completeTransition(c)
                }
            }

        }
    }
}

extension QXBookReaderVc {
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return theme.isDark ? .lightContent : .darkContent
        } else {
            return theme.isDark ? .lightContent : .default
        }
    }
    
}
