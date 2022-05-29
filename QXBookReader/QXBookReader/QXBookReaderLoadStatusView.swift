//
//  QXBookReaderLoadView.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/10.
//

import UIKit

public enum QXBookReaderLoadStatus {
    case loading(String)
    case ok
    case error(String)
}

public class QXBookReaderLoadStatusView: UIView {
    
    public var theme: QXBookReaderTheme? {
        didSet {
            if let e = theme {
                if e.isDark {
                    indicatorView.style = .white
                } else {
                    indicatorView.style = .gray
                }
                backgroundColor = e.backgroundColor
            }
        }
    }
    
    public var status: QXBookReaderLoadStatus = .ok {
        didSet {
            switch status {
            case .loading(let msg):
                indicatorView.startAnimating()
                indicatorView.isHidden = false
                messageLabel.text = msg
                self.isHidden = false
            case .ok:
                self.isHidden = true
            case .error(let msg):
                indicatorView.stopAnimating()
                indicatorView.isHidden = true
                messageLabel.text = msg
                self.isHidden = false
            }
            setNeedsLayout()
        }
    }
    
    public lazy var messageLabel: UILabel = {
        let e = UILabel()
        e.font = UIFont.systemFont(ofSize: 14)
        e.textColor = QXBookReaderConfigs.subTextColor
        return e
    }()
    public lazy var indicatorView: UIActivityIndicatorView = {
        let e = UIActivityIndicatorView()
        return e
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(indicatorView)
        addSubview(messageLabel)
        self.isHidden = true
        backgroundColor = QXBookReaderConfigs.backgroundColor
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let sw = bounds.size.width
        let sh = bounds.size.height
        do {
            let _size = messageLabel.sizeThatFits(CGSize(width: sw - 50 * 2, height: CGFloat.greatestFiniteMagnitude))
            let h = _size.height
            let w = _size.width
            messageLabel.frame = CGRect(x: (sw - w) / 2,
                                        y: (sh - h) / 2,
                                        width: w,
                                        height: h)
        }
        do {
            indicatorView.sizeToFit()
            let w = indicatorView.frame.size.width
            let h = indicatorView.frame.size.height
            indicatorView.frame = CGRect(x: (sw - w) / 2,
                                         y: messageLabel.frame.minY - 15 - h,
                                         width: w,
                                         height: h)
        }
    }
    
}
