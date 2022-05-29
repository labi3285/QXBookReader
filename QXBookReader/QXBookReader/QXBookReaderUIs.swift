//
//  QXBookReaderBarViews.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/10.
//

import UIKit

open class QXBookReaderDashLineView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        setNeedsDisplay()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        ctx.saveGState()
        ctx.setStrokeColor(UIColor.gray.cgColor)
        ctx.setLineWidth(1)
        ctx.move(to: CGPoint(x: rect.minX, y: rect.midY - 0.5))
        ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - 0.5))
        ctx.setLineDash(phase: 0, lengths: [3, 1])
        ctx.strokePath()
        ctx.restoreGState()
    }
}

open class QXBookReaderSlider: UISlider {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        minimumTrackTintColor = QXBookReaderConfigs.tintColor
        minimumValue = 0
        maximumValue = 1
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

open class QXBookReaderTitleButton: QXBookReaderButton {
        
    open var title: String? {
        didSet {
            myTitleLabel.text = title
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            if isSelected {
                myTitleLabel.textColor = QXBookReaderConfigs.tintColor
            } else {
                myTitleLabel.textColor = QXBookReaderConfigs.buttonTitleColor
            }
        }
    }
    
    public lazy var myTitleLabel: UILabel = {
        let e = UILabel()
        e.textColor = QXBookReaderConfigs.barShadowColor
        e.font = UIFont.systemFont(ofSize: 14)
        e.textAlignment = .center
        return e
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(myTitleLabel)
        addTarget(self, action: #selector(onClick), for: .touchUpInside)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        myTitleLabel.frame = bounds
    }
}

open class QXBookReaderBorderTitleButton: QXBookReaderButton {
        
    public override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            if isSelected {
                myTitleLabel.textColor = QXBookReaderConfigs.tintColor
                layer.borderColor = QXBookReaderConfigs.tintColor.cgColor
            } else {
                myTitleLabel.textColor = QXBookReaderConfigs.titleColor
                layer.borderColor = QXBookReaderConfigs.buttonBorderColor.cgColor
            }
        }
    }
    
    open var title: String? {
        didSet {
            myTitleLabel.text = title
        }
    }
    public lazy var myTitleLabel: UILabel = {
        let e = UILabel()
        e.textColor = QXBookReaderConfigs.titleColor
        e.font = UIFont.systemFont(ofSize: 14)
        e.textAlignment = .center
        return e
    }()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        layer.borderColor = QXBookReaderConfigs.buttonBorderColor.cgColor
        layer.cornerRadius = 5
        addSubview(myTitleLabel)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        myTitleLabel.frame = bounds
    }
}

open class QXBookReaderBorderIconButton: QXBookReaderIconButton {
    
    public override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            if isSelected {
                layer.borderColor = QXBookReaderConfigs.tintColor.cgColor
            } else {
                layer.borderColor = QXBookReaderConfigs.buttonBorderColor.cgColor
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        layer.borderColor = QXBookReaderConfigs.buttonBorderColor.cgColor
        layer.cornerRadius = 5
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

open class QXBookReaderPageMarkButton: QXBookReaderButton {
            
    public override var isSelected: Bool {
        didSet {
            if isSelected {
                iconView.tintColor = QXBookReaderConfigs.tintColor
                var image = QXBookReaderResources.image("icon_page_mark1")
                image = image?.withRenderingMode(.alwaysTemplate)
                iconView.image = image
            } else {
                iconView.tintColor = QXBookReaderConfigs.buttonTitleColor
                var image = QXBookReaderResources.image("icon_page_mark0")
                image = image?.withRenderingMode(.alwaysTemplate)
                iconView.image = image
            }
            super.isSelected = isSelected
        }
    }
    
    open var iconSize: CGSize?
    open var margin: UIEdgeInsets?
    
    public lazy var iconView: UIImageView = {
        let e = UIImageView()
        var image = QXBookReaderResources.image("icon_page_mark0")
        image = image?.withRenderingMode(.alwaysTemplate)
        e.image = image
        e.tintColor = QXBookReaderConfigs.buttonTitleColor
        return e
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconView)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let size = iconSize, let margin = margin {
            let gw = bounds.width - margin.left - margin.right
            let gh = bounds.height - margin.top - margin.bottom
            var w = size.width
            var h = size.height
            w = min(gw, w)
            h = min(gh, h)
            let x = margin.left + (gw - w) / 2
            let y = margin.top + (gh - h) / 2
            iconView.frame = CGRect(x: x, y: y, width: w, height: h)
        } else if let size = iconSize {
            iconView.frame = CGRect(x: (bounds.width - size.width) / 2, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
        } else if let margin = margin {
            iconView.frame = bounds.inset(by: margin)
        } else {
            iconView.frame = bounds
        }
    }
}

open class QXBookReaderIconButton: QXBookReaderButton {
            
    public override var isSelected: Bool {
        didSet {
            if isSelected {
                iconView.tintColor = QXBookReaderConfigs.tintColor
            } else {
                iconView.tintColor = QXBookReaderConfigs.buttonTitleColor
            }
            super.isSelected = isSelected
        }
    }
    
    open var imageNamed: String? {
        didSet {
            if let e = imageNamed {
                var image = QXBookReaderResources.image(e)
                image = image?.withRenderingMode(.alwaysTemplate)
                if isSelected {
                    iconView.tintColor = QXBookReaderConfigs.tintColor
                } else {
                    iconView.tintColor = QXBookReaderConfigs.buttonTitleColor
                }
                iconView.image = image
            } else {
                iconView.image = nil
            }
        }
    }
    
    open var iconSize: CGSize?
    open var margin: UIEdgeInsets?
    
    public lazy var iconView: UIImageView = {
        let e = UIImageView()
        e.tintColor = QXBookReaderConfigs.buttonTitleColor
        return e
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconView)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let size = iconSize, let margin = margin {
            let gw = bounds.width - margin.left - margin.right
            let gh = bounds.height - margin.top - margin.bottom
            var w = size.width
            var h = size.height
            w = min(gw, w)
            h = min(gh, h)
            let x = margin.left + (gw - w) / 2
            let y = margin.top + (gh - h) / 2
            iconView.frame = CGRect(x: x, y: y, width: w, height: h)
        } else if let size = iconSize {
            iconView.frame = CGRect(x: (bounds.width - size.width) / 2, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
        } else if let margin = margin {
            iconView.frame = bounds.inset(by: margin)
        } else {
            iconView.frame = bounds
        }
    }
}

open class QXBookReaderButton: UIButton {
    
    open var respondClick: (() -> Void)?
    
    open var enableClick: Bool = true {
        didSet {
            alpha = enableClick ? 1 : 0.3
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(onClick), for: .touchUpInside)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func onClick() {
        if enableClick {
            respondClick?()
        }
    }
    
}
