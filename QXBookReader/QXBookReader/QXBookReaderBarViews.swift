//
//  QXBookReaderBarViews.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/13.
//

import UIKit

public protocol QXBookReaderTopBarViewDelegate: AnyObject {
    
    func topBarViewCloseBook(_ barView: QXBookReaderTopBarView)
    
    func topBarViewGetTitle(_ barView: QXBookReaderTopBarView) -> String

    func topBarViewGetIsPageMarked(_ barView: QXBookReaderTopBarView, done: (_ isPageMarked: Bool) -> Void)
    func topBarViewMarkPage(_ barView: QXBookReaderTopBarView, isMark: Bool, done: (_ isOk: Bool) -> Void)
    
}
open class QXBookReaderTopBarView: UIView {
    
    open var height: CGFloat {
        return QXBookReaderUtils.getStatusBarHeight() + 44
    }
    
    public weak var delegate: QXBookReaderTopBarViewDelegate? {
        didSet {
            update()
        }
    }
    
    open func update() {
        if let d = delegate {
            titleLabel.text = d.topBarViewGetTitle(self)
            weak var ws = self
            d.topBarViewGetIsPageMarked(self) { isPageMarked in
                ws?.pageMarkButton.isSelected = isPageMarked
            }
        }
    }
    
    public lazy var effectView: UIVisualEffectView = {
        let e = UIVisualEffectView(effect: nil)
        return e
    }()
    
    public lazy var titleLabel: UILabel = {
        let e = UILabel()
        e.textAlignment = .center
        e.font = UIFont.systemFont(ofSize: 14)
        e.textColor = QXBookReaderConfigs.titleColor
        return e
    }()
    
    public lazy var backButton: QXBookReaderIconButton = {
        let e = QXBookReaderIconButton()
        e.imageNamed = "icon_back"
        e.iconSize = CGSize(width: 18, height: 18)
        e.respondClick = { [weak self] in
            if let s = self {
                self?.delegate?.topBarViewCloseBook(s)
            }
        }
        return e
    }()
    public lazy var pageMarkButton: QXBookReaderPageMarkButton = {
        let e = QXBookReaderPageMarkButton()
        e.iconSize = CGSize(width: 20, height: 20)
        e.respondClick = { [weak self, weak e] in
            if let s = self, let d = s.delegate, let e = e {
                d.topBarViewGetIsPageMarked(s) { isPageMarked in
                    d.topBarViewMarkPage(s, isMark: !isPageMarked) { isOk in
                        if isOk {
                            e.isSelected = !isPageMarked
                        }
                    }
                }
            }
        }
        return e
    }()
    

    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0.6)
        layer.shadowRadius = 0
        layer.shadowColor = QXBookReaderConfigs.barShadowColor.cgColor
        backgroundColor = QXBookReaderConfigs.barBackgroundColor
        addSubview(titleLabel)
        addSubview(backButton)
        addSubview(pageMarkButton)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        applicationDidBecomeActiveNotification()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let top = QXBookReaderUtils.getStatusBarHeight()
        backButton.frame = CGRect(x: 0, y: top, width: 44, height: 44)
        pageMarkButton.frame = CGRect(x: bounds.width - 44, y: top, width: 44, height: 44)
        titleLabel.frame = CGRect(x: 44, y: top, width: bounds.width - 44 * 2, height: 44)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc public func applicationDidBecomeActiveNotification() {
        if QXBookReaderUtils.getIsDarkMode() {
            effectView.effect = UIBlurEffect(style: .dark)
        } else {
            effectView.effect = UIBlurEffect(style: .light)
        }
    }
}

public protocol QXBookReaderBottomBarViewDelegate: AnyObject {
    
    func bottomBarViewShowIndex(_ barView: QXBookReaderBottomBarView)
    
    func bottomBarViewGetChapterPageIndexInfo(_ barView: QXBookReaderBottomBarView) -> (pageIndex: Int, total: Int)
    func bottomBarViewGoToChapterPageIndex(_ barView: QXBookReaderBottomBarView, pageIndex: Int)
    
    func bottomBarViewShowSettings(_ barView: QXBookReaderBottomBarView)
    
    func bottomBarViewCanPrevChapter(_ barView: QXBookReaderBottomBarView) -> Bool
    func bottomBarViewGoPrevChapter(_ barView: QXBookReaderBottomBarView)
    
    func bottomBarViewCanNextChapter(_ barView: QXBookReaderBottomBarView) -> Bool
    func bottomBarViewGoNextChapter(_ barView: QXBookReaderBottomBarView)
    
}

open class QXBookReaderProgessBubbleView: UIView {
    
    public var color: UIColor = QXBookReaderConfigs.tintColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var text: String?
    
    public lazy var textLabel: UILabel = {
        let e = UILabel()
        e.font = UIFont.boldSystemFont(ofSize: 14)
        e.textColor = UIColor.white
        e.textAlignment = .center
        return e
    }()
    
    open override var isHidden: Bool {
        didSet {
            super.isHidden = isHidden
            setNeedsDisplay()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        setNeedsDisplay()
        addSubview(textLabel)
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let pointerH: CGFloat = 6
        textLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - pointerH)
    }

    open override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        ctx.saveGState()
        let pointerW: CGFloat = 4
        let pointerH: CGFloat = 6
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: rect.width, height: rect.height - pointerH), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 3, height: 3))
        ctx.addPath(path.cgPath)
        ctx.move(to: CGPoint(x: rect.midX - pointerW / 2, y: rect.height - pointerH))
        ctx.addLine(to: CGPoint.init(x: rect.midX + pointerW / 2, y: rect.height - pointerH))
        ctx.addLine(to: CGPoint.init(x: rect.midX, y: rect.height))
        ctx.closePath()
        ctx.setLineWidth(0)
        ctx.setFillColor(color.cgColor)
        ctx.fillPath()
        ctx.restoreGState()
    }
    
}

open class QXBookReaderBottomBarView: UIView {
    
    open var height: CGFloat {
        return 44 + 1 + 44 + QXBookReaderUtils.getBottomAppendHeight()
    }
    
    public weak var delegate: QXBookReaderBottomBarViewDelegate? {
        didSet {
            update()
        }
    }
    
    open func update() {
        if let d = delegate {
            prevChapterButton.enableClick = d.bottomBarViewCanPrevChapter(self)
            nextChapterButton.enableClick = d.bottomBarViewCanNextChapter(self)
            
            let p = d.bottomBarViewGetChapterPageIndexInfo(self)
            progressSlider.value = Float(p.pageIndex) / Float(p.total - 1)
        }
    }
    
    public lazy var effectView: UIVisualEffectView = {
        let e = UIVisualEffectView(effect: nil)
        return e
    }()
    
    public lazy var prevChapterButton: QXBookReaderTitleButton = {
        let e = QXBookReaderTitleButton()
        e.title = "上一章"
        e.respondClick = { [weak self, weak e] in
            if let s = self, let d = s.delegate {
                if d.bottomBarViewCanPrevChapter(s) {
                    d.bottomBarViewGoPrevChapter(s)
                    s.prevChapterButton.enableClick = d.bottomBarViewCanPrevChapter(s)
                    s.nextChapterButton.enableClick = d.bottomBarViewCanNextChapter(s)
                }
            }
        }
        return e
    }()
    lazy var progressBubbleView: QXBookReaderProgessBubbleView = {
        let e = QXBookReaderProgessBubbleView()
        return e
    }()
    public lazy var progressSlider: QXBookReaderSlider = {
        let e = QXBookReaderSlider()
        e.addTarget(self, action: #selector(progressSliderTouchDown), for: .touchDown)
        e.addTarget(self, action: #selector(progressSliderTouchUpOutside), for: .touchUpOutside)
        e.addTarget(self, action: #selector(progressSliderTouchUpInside), for: .touchUpInside)
        e.addTarget(self, action: #selector(progressSliderValueChanged), for: .valueChanged)
        e.addTarget(self, action: #selector(progressSliderTouchCancel), for: .touchCancel)
        return e
    }()
    
    @objc public func progressSliderTouchDown() {
        _updateProgessBubbleViewFrame()
        progressBubbleView.isHidden = false
    }
    @objc public func progressSliderTouchUpInside() {
        progressBubbleView.isHidden = true
        _onSliderEnd()
    }
    @objc public func progressSliderTouchUpOutside() {
        progressBubbleView.isHidden = true
        _onSliderEnd()
    }
    @objc public func progressSliderValueChanged() {
        _updateProgessBubbleViewFrame()
    }
    @objc public func progressSliderTouchCancel() {
        progressBubbleView.isHidden = true
        _onSliderEnd()
    }
    private func _updateProgessBubbleViewFrame() {
        let _minX = progressSlider.frame.minX + 15
        let _maxX = progressSlider.frame.maxX - 15
        let _centerX = _minX + (_maxX - _minX) * CGFloat(progressSlider.value)
        if let d = delegate {
            let v = progressSlider.value
            let p = d.bottomBarViewGetChapterPageIndexInfo(self)
            progressBubbleView.textLabel.text = "\(Int(Float(p.total - 1) * v) + 1)/\(p.total)"
        } else {
            progressBubbleView.textLabel.text = String(format: "%.2f%%", progressSlider.value * 100)
        }
        progressBubbleView.frame = CGRect(x: _centerX - 60 / 2, y: -45, width: 60, height: 40)
        bringSubviewToFront(progressBubbleView)
    }
    private func _onSliderEnd() {
        if let d = delegate {
            let v = progressSlider.value
            let p = d.bottomBarViewGetChapterPageIndexInfo(self)
            let pageIndex = Int(Float(p.total - 1) * v)
            d.bottomBarViewGoToChapterPageIndex(self, pageIndex: pageIndex)
        }
    }
    
    public lazy var nextChapterButton: QXBookReaderTitleButton = {
        let e = QXBookReaderTitleButton()
        e.title = "下一章"
        e.respondClick = { [weak self, weak e] in
            if let s = self, let d = s.delegate {
                if d.bottomBarViewCanNextChapter(s) {
                    d.bottomBarViewGoNextChapter(s)
                    s.prevChapterButton.enableClick = d.bottomBarViewCanPrevChapter(s)
                    s.nextChapterButton.enableClick = d.bottomBarViewCanNextChapter(s)
                }
            }
        }
        return e
    }()
    
    public lazy var breakView: QXBookReaderDashLineView = {
        let e = QXBookReaderDashLineView()
        return e
    }()
    
    public lazy var chapteresButton: QXBookReaderIconButton = {
        let e = QXBookReaderIconButton()
        e.imageNamed = "icon_chapters"
        e.iconSize = CGSize(width: 18, height: 18)
        e.respondClick = { [weak self, weak e] in
            if let s = self, let d = s.delegate, let e = e {
                d.bottomBarViewShowIndex(s)
            }
        }
        return e
    }()
    
    public lazy var settingsButton: QXBookReaderIconButton = {
        let e = QXBookReaderIconButton()
        e.imageNamed = "icon_font"
        e.iconSize = CGSize(width: 18, height: 18)
        e.respondClick = { [weak self, weak e] in
            if let s = self, let d = s.delegate, let e = e {
                d.bottomBarViewShowSettings(s)
            }
        }
        return e
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: -0.6)
        layer.shadowRadius = 0
        layer.shadowColor = QXBookReaderConfigs.barShadowColor.cgColor
        backgroundColor = QXBookReaderConfigs.barBackgroundColor
        addSubview(prevChapterButton)
        addSubview(progressSlider)
        addSubview(progressBubbleView)
        addSubview(nextChapterButton)
        addSubview(breakView)
        addSubview(chapteresButton)
        addSubview(settingsButton)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        applicationDidBecomeActiveNotification()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        prevChapterButton.frame = CGRect(x: 0, y: 0, width: 70, height: 44)
        progressSlider.frame = CGRect(x: 70, y: 0, width: bounds.width - 70 * 2, height: 44)
        nextChapterButton.frame = CGRect(x: bounds.width - 70, y: 0, width: 70, height: 44)
        breakView.frame = CGRect(x: 0, y: 44, width: bounds.width, height: 1)
        chapteresButton.frame = CGRect(x: 5, y: 44 + 1, width: 44, height: 44)
        settingsButton.frame = CGRect(x: bounds.width - 44 - 5, y: 44 + 1, width: 44, height: 44)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc public func applicationDidBecomeActiveNotification() {
        if QXBookReaderUtils.getIsDarkMode() {
            effectView.effect = UIBlurEffect(style: .dark)
        } else {
            effectView.effect = UIBlurEffect(style: .light)
        }
    }
}


open class QXBookReaderChapterTopBarView: UIView {
    
    public static var height: CGFloat {
        return QXBookReaderUtils.getStatusBarHeight() + 44
    }
    open var height: CGFloat {
        return QXBookReaderChapterTopBarView.height
    }
    
    public private(set) var selectIndex: Int = 0
    
    public var respondSelect: ((_ i: Int) -> Void)?
    
    public lazy var effectView: UIVisualEffectView = {
        let e = UIVisualEffectView(effect: nil)
        return e
    }()
    public lazy var titleButton0: QXBookReaderTitleButton = {
        let e = QXBookReaderTitleButton()
        e.myTitleLabel.font = UIFont.systemFont(ofSize: 16)
        e.title = "目录"
        e.isSelected = true
        e.respondClick = { [weak self] in
            if let s = self {
                s.selectIndex = 0
                s.titleButton0.isSelected = true
                s.titleButton1.isSelected = false
                s.setNeedsLayout()
                s.respondSelect?(0)
            }
        }
        return e
    }()
    public lazy var titleButton1: QXBookReaderTitleButton = {
        let e = QXBookReaderTitleButton()
        e.myTitleLabel.font = UIFont.systemFont(ofSize: 16)
        e.title = "书签"
        e.respondClick = { [weak self] in
            if let s = self {
                s.selectIndex = 1
                s.titleButton0.isSelected = false
                s.titleButton1.isSelected = true
                s.setNeedsLayout()
                s.respondSelect?(1)
            }
        }
        return e
    }()
    public lazy var lineView: UIView = {
        let e = UIView()
        e.backgroundColor = QXBookReaderConfigs.tintColor
        return e
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0.6)
        layer.shadowRadius = 0
        layer.shadowColor = QXBookReaderConfigs.barShadowColor.cgColor
        backgroundColor = QXBookReaderConfigs.barBackgroundColor
        addSubview(titleButton0)
        addSubview(titleButton1)
        addSubview(lineView)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        applicationDidBecomeActiveNotification()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let lineH: CGFloat = 2
        let lineW: CGFloat = 50
        let buttonW: CGFloat = 60
        var y = QXBookReaderUtils.getStatusBarHeight()
        var x = (bounds.width - buttonW * 2) / 2
        titleButton0.frame = CGRect(x: x, y: y, width: buttonW, height: 44 - lineH)
        x += buttonW
        titleButton1.frame = CGRect(x: x, y: y, width: buttonW, height: 44 - lineH)
        y += (44 - lineH)
        let lineX = (bounds.width - buttonW * 2) / 2 + buttonW * CGFloat(selectIndex) + (buttonW - lineW) / 2
        lineView.frame = CGRect(x: lineX, y: y, width: lineW, height: lineH)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc public func applicationDidBecomeActiveNotification() {
        if QXBookReaderUtils.getIsDarkMode() {
            effectView.effect = UIBlurEffect(style: .dark)
        } else {
            effectView.effect = UIBlurEffect(style: .light)
        }
    }
}
