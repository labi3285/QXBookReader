//
//  QXBookReaderConfigsVc.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/11.
//

import UIKit

public protocol QXBookReaderSettingsVcDelegate: AnyObject {
    
    func settingsVcGetBrightness(_ settingsVc: QXBookReaderSettingsVc) -> Double
    func settingsVcSetBrightness(_ settingsVc: QXBookReaderSettingsVc, brightness: Double)
    
    func settingsVcCanMinusFontSize(_ settingsVc: QXBookReaderSettingsVc) -> Bool
    func settingsVcCanPlusFontSize(_ settingsVc: QXBookReaderSettingsVc) -> Bool
    func settingsVcGetFontSize(_ settingsVc: QXBookReaderSettingsVc) -> Int
    func settingsVcSetFontSize(_ settingsVc: QXBookReaderSettingsVc, fontSize: Int)

    func settingsVcGetPageMode(_ settingsVc: QXBookReaderSettingsVc) -> QXBookReaderPageMode
    func settingsVcSetPageMode(_ settingsVc: QXBookReaderSettingsVc, pageMode: QXBookReaderPageMode)

    func settingsVcGetTheme(_ settingsVc: QXBookReaderSettingsVc) -> QXBookReaderTheme
    func settingsVcSetTheme(_ settingsVc: QXBookReaderSettingsVc, theme: QXBookReaderTheme)

    func settingsVcGetLineHeightRate(_ settingsVc: QXBookReaderSettingsVc) -> CGFloat
    func settingsVcSetLineHeightRate(_ settingsVc: QXBookReaderSettingsVc, rate: CGFloat)

}

public class QXBookReaderSettingsVc: UIViewController {
        
    public let height: CGFloat = 205 + QXBookReaderUtils.getBottomAppendHeight()
    
    public weak var delegate: QXBookReaderSettingsVcDelegate? {
        didSet {
            update()
        }
    }
    
    open func update() {
        if let d = delegate {
            lightSlider.value = Float(d.settingsVcGetBrightness(self))
            fontSizeMinusButton.enableClick = d.settingsVcCanMinusFontSize(self)
            fontSizePlusButton.enableClick = d.settingsVcCanPlusFontSize(self)
            fontSizeLabel.text = "\(d.settingsVcGetFontSize(self))"
            pageButton.isSelected = d.settingsVcGetPageMode(self) == .page
            let _theme = d.settingsVcGetTheme(self)
            for (i, v) in themeButtons.enumerated() {
                v.isSelected = QXBookReaderTheme.themes[i].code == _theme.code
            }
            
            let _lineSpaceRate = d.settingsVcGetLineHeightRate(self)
            lineSpace0Button.isSelected = _lineSpaceRate == 1.2
            lineSpace1Button.isSelected = _lineSpaceRate == 1.4
            lineSpace2Button.isSelected = _lineSpaceRate == 1.6
        }
    }
    
    public lazy var light0Button: QXBookReaderIconButton = {
        let e = QXBookReaderIconButton()
        e.imageNamed = "icon_light_0"
        e.iconSize = CGSize(width: 18, height: 18)
        return e
    }()
    public lazy var lightSlider: QXBookReaderSlider = {
        let e = QXBookReaderSlider()
        e.addTarget(self, action: #selector(lightSliderValueChanged), for: .valueChanged)
        return e
    }()
    @objc public func lightSliderValueChanged() {
        delegate?.settingsVcSetBrightness(self, brightness: Double(lightSlider.value))
    }
    public lazy var light1Button: QXBookReaderIconButton = {
        let e = QXBookReaderIconButton()
        e.imageNamed = "icon_light_1"
        e.iconSize = CGSize(width: 18, height: 18)
        return e
    }()
    public lazy var breakView: QXBookReaderDashLineView = {
        let e = QXBookReaderDashLineView()
        return e
    }()
    
    public lazy var fontSizeMinusButton: QXBookReaderBorderTitleButton = {
        let e = QXBookReaderBorderTitleButton()
        e.title = "A-"
        e.respondClick = { [weak self, weak e] in
            if let s = self, let d = s.delegate {
                if d.settingsVcCanMinusFontSize(s) {
                    let fontSize = d.settingsVcGetFontSize(s) - 2
                    d.settingsVcSetFontSize(s, fontSize: fontSize )
                    s.fontSizeMinusButton.enableClick = d.settingsVcCanMinusFontSize(s)
                    s.fontSizePlusButton.enableClick = d.settingsVcCanPlusFontSize(s)
                    s.fontSizeLabel.text = "\(fontSize)"
                }
            }
        }
        return e
    }()
    public lazy var fontSizeLabel: UILabel = {
        let e = UILabel()
        e.textAlignment = .center
        e.font = UIFont.systemFont(ofSize: 18)
        e.textColor = QXBookReaderConfigs.titleColor
        return e
    }()
    public lazy var fontSizePlusButton: QXBookReaderBorderTitleButton = {
        let e = QXBookReaderBorderTitleButton()
        e.title = "A+"
        e.respondClick = { [weak self, weak e] in
            if let s = self, let d = s.delegate {
                if d.settingsVcCanPlusFontSize(s) {
                    let fontSize = d.settingsVcGetFontSize(s) + 2
                    d.settingsVcSetFontSize(s, fontSize: fontSize)
                    s.fontSizeMinusButton.enableClick = d.settingsVcCanMinusFontSize(s)
                    s.fontSizePlusButton.enableClick = d.settingsVcCanPlusFontSize(s)
                    s.fontSizeLabel.text = "\(fontSize)"
                }
            }
        }
        return e
    }()
    public lazy var fontButton: QXBookReaderBorderTitleButton = {
        let e = QXBookReaderBorderTitleButton()
        e.title = "字体"
        return e
    }()
    
    public lazy var pageButton: QXBookReaderBorderTitleButton = {
        let e = QXBookReaderBorderTitleButton()
        e.title = "翻页"
        e.respondClick = { [weak self] in
            if let s = self, let d = s.delegate {
                switch d.settingsVcGetPageMode(s) {
                case .page:
                    d.settingsVcSetPageMode(s, pageMode: .scroll)
                    s.pageButton.isSelected = false
                case .scroll:
                    d.settingsVcSetPageMode(s, pageMode: .page)
                    s.pageButton.isSelected = true
                }
            }
        }
        return e
    }()
    
    public lazy var themeButtons: [QXBookReaderBorderTitleButton] = {
        return QXBookReaderTheme.themes.map { m in
            let e = QXBookReaderBorderTitleButton()
            e.title = ""
            e.backgroundColor = m.backgroundColor
            e.respondClick = { [weak self] in
                if let s = self, let d = s.delegate {
                    var _theme = d.settingsVcGetTheme(s)
                    if _theme.code != m.code {
                        d.settingsVcSetTheme(s, theme: m)
                        let _theme = d.settingsVcGetTheme(s)
                        for (i, v) in s.themeButtons.enumerated() {
                            v.isSelected = QXBookReaderTheme.themes[i].code == _theme.code
                        }
                    }
                }
            }
            return e
        }
    }()
    
    public lazy var lineSpace0Button: QXBookReaderBorderIconButton = {
        let e = QXBookReaderBorderIconButton()
        e.imageNamed = "icon_line_space0"
        e.iconSize = CGSize(width: 18, height: 18)
        e.respondClick = { [weak self, weak e] in
            if let s = self, let d = s.delegate, let e = e {
                let rate = d.settingsVcGetLineHeightRate(s)
                if rate != 1.2 {
                    d.settingsVcSetLineHeightRate(s, rate: 1.2)
                    s.lineSpace0Button.isSelected = true
                    s.lineSpace1Button.isSelected = false
                    s.lineSpace2Button.isSelected = false
                }
            }
        }
        return e
    }()
    public lazy var lineSpace1Button: QXBookReaderBorderIconButton = {
        let e = QXBookReaderBorderIconButton()
        e.imageNamed = "icon_line_space1"
        e.iconSize = CGSize(width: 18, height: 18)
        e.respondClick = { [weak self, weak e] in
            if let s = self, let d = s.delegate, let e = e {
                let rate = d.settingsVcGetLineHeightRate(s)
                if rate != 1.4 {
                    d.settingsVcSetLineHeightRate(s, rate: 1.4)
                    s.lineSpace0Button.isSelected = false
                    s.lineSpace1Button.isSelected = true
                    s.lineSpace2Button.isSelected = false
                }
            }
        }
        return e
    }()
    public lazy var lineSpace2Button: QXBookReaderBorderIconButton = {
        let e = QXBookReaderBorderIconButton()
        e.imageNamed = "icon_line_space2"
        e.iconSize = CGSize(width: 18, height: 18)
        e.respondClick = { [weak self, weak e] in
            if let s = self, let d = s.delegate, let e = e {
                let rate = d.settingsVcGetLineHeightRate(s)
                if rate != 1.6 {
                    d.settingsVcSetLineHeightRate(s, rate: 1.6)
                    s.lineSpace0Button.isSelected = false
                    s.lineSpace1Button.isSelected = false
                    s.lineSpace2Button.isSelected = true
                }
            }
        }
        return e
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(light0Button)
        view.addSubview(lightSlider)
        view.addSubview(light1Button)
        view.addSubview(breakView)
        
        view.addSubview(fontSizeMinusButton)
        view.addSubview(fontSizeLabel)
        view.addSubview(fontSizePlusButton)
        view.addSubview(fontButton)
        view.addSubview(pageButton)
        
        for v in themeButtons {
            view.addSubview(v)
        }
        
        view.addSubview(lineSpace0Button)
        view.addSubview(lineSpace1Button)
        view.addSubview(lineSpace2Button)
    }

    public required init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: -0.6)
        view.layer.shadowRadius = 0
        view.layer.shadowColor = QXBookReaderConfigs.barShadowColor.cgColor
        view.backgroundColor = QXBookReaderConfigs.barBackgroundColor
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let sw = view.bounds.width
        let sh = view.bounds.height
        let tw = min(400, sw)
        var y: CGFloat = 0
        do {
            light0Button.frame = CGRect(x: 0, y: y, width: 44, height: 44)
            lightSlider.frame = CGRect(x: 44, y: y, width: sw - 44 * 2, height: 44)
            light1Button.frame = CGRect(x: sw - 44, y: y, width: 44, height: 44)
            y += 44
        }
        do {
            breakView.frame = CGRect(x: 0, y: y, width: sw, height: 1)
            y += 1
        }
        do {
            y += 5
            y += 10
            let x = (sw - tw) / 2
            let dw = (tw - 15 * 2 - 5 * 2 - 20 - 60 - 20 - 50) / 3
            fontSizeMinusButton.frame = CGRect(x: x + 15, y: y, width: dw, height: 30)
            fontSizeLabel.frame = CGRect(x: fontSizeMinusButton.frame.maxX + 5, y: y, width: dw, height: 30)
            fontSizePlusButton.frame = CGRect(x: fontSizeLabel.frame.maxX + 5, y: y, width: dw, height: 30)
            fontButton.frame = CGRect(x: fontSizePlusButton.frame.maxX + 20, y: y, width: 60, height: 30)
            pageButton.frame = CGRect(x: fontButton.frame.maxX + 20, y: y, width: 50, height: 30)
            y += 30
            y += 10
        }
        do {
            y += 10
            var x = (sw - tw) / 2
            let dw = (tw - 15 * 2 - 10 * CGFloat(themeButtons.count - 1)) /  CGFloat(themeButtons.count)
            x += 15
            for v in themeButtons {
                v.frame = CGRect(x: x, y: y, width: dw, height: 30)
                x += (dw + 10)
            }
            y += 30
            y += 10
        }
        do {
            y += 10
            let x = (sw - tw) / 2
            let dw = (tw - 15 * 2 - 30 * 2) / 3
            lineSpace0Button.frame = CGRect(x: x + 15, y: y, width: dw, height: 30)
            lineSpace1Button.frame = CGRect(x: lineSpace0Button.frame.maxX + 30, y: y, width: dw, height: 30)
            lineSpace2Button.frame = CGRect(x: lineSpace1Button.frame.maxX + 30, y: y, width: dw, height: 30)
            y += 30
            y += 10
        }
        
//        fontSizeMinusButton.frame =

        
//        chaptersVc.view.frame = view.bounds
//        loadStatusView.frame = view.bounds
//        topBarView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topBarView.height)
//        tableView.frame = view.bounds
//        bottomBarView.frame = CGRect(x: 0, y: view.bounds.height - bottomBarView.height, width: view.bounds.width, height: bottomBarView.height)
    }

    private var _isPresent = true
    private lazy var _coverView: UIButton = {
        let e = UIButton()
        e.backgroundColor = UIColor.clear
        e.addTarget(self, action: #selector(_coverViewClick), for: .touchUpInside)
        return e
    }()
    @objc public func _coverViewClick() {
        dismiss(animated: true, completion: nil)
    }
}

extension QXBookReaderSettingsVc: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
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
            return 0.3
        } else {
            return 0.3
        }
    }
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromVc = transitionContext.viewController(forKey: .from)!
        let toVc = transitionContext.viewController(forKey: .to)!
        if _isPresent {
            containerView.addSubview(_coverView)
            _coverView.frame = containerView.bounds
            containerView.addSubview(toVc.view)
            toVc.view.frame = CGRect(x: 0, y: containerView.bounds.height, width: containerView.bounds.width, height: height)
            UIView.animate(withDuration: 0.3) {
                toVc.view.frame = CGRect(x: 0, y: containerView.bounds.height - self.height, width: containerView.bounds.width, height: self.height)
            } completion: { c in
                transitionContext.completeTransition(c)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                fromVc.view.frame = CGRect(x: 0, y: containerView.bounds.height, width: containerView.bounds.width, height: self.height)
            } completion: { c in
                self._coverView.removeFromSuperview()
                fromVc.view.removeFromSuperview()
                transitionContext.completeTransition(c)
            }
        }
    }
}
