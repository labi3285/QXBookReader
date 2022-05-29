//
//  QXBookReaderIndexVc.swift
//  QXBookReader
//
//  Created by labi3285 on 2022/2/11.
//

import UIKit

public class QXBookReaderIndexVc: UIViewController {
    
    public var width: CGFloat = UIScreen.main.bounds.width > 350 ? 300 : 270
    
    public var respondSelectChapter: ((_ chapter: QXBookIndex) -> Void)?

    public var bringInIndex: QXBookIndex?
    public var indexes: [QXBookIndex]!
    
    public var respondSelectPageMark: ((_ pageMark: QXBookPageMark) -> Void)?
    public var pageMarks: [QXBookPageMark]!
        
    public lazy var topBarView: QXBookReaderChapterTopBarView = {
        let e = QXBookReaderChapterTopBarView()
        e.respondSelect = { [weak self] i in
            self?.loadData()
        }
        return e
    }()
    
    public lazy var loadStatusView: QXBookReaderLoadStatusView = {
        let e = QXBookReaderLoadStatusView()
        return e
    }()
    public lazy var tableView: UITableView = {
        let e = UITableView(frame: CGRect.zero, style: .plain)
        e.separatorStyle = .none
        e.register(QXBookReaderChapterIndexCell.self, forCellReuseIdentifier: "QXBookReaderChapterIndexCell")
        e.register(QXBookReaderPageMarkCell.self, forCellReuseIdentifier: "QXBookReaderPageMarkCell")
        e.delegate = self
        e.dataSource = self
        e.backgroundColor = QXBookReaderConfigs.backgroundLightGrayColor
        if #available(iOS 13.0, *) {
            e.automaticallyAdjustsScrollIndicatorInsets = false
            e.contentInsetAdjustmentBehavior = .never
        } else {
        }
        return e
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = QXBookReaderConfigs.backgroundLightGrayColor
        view.addSubview(tableView)
        view.addSubview(loadStatusView)
        view.addSubview(topBarView)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self._selectIndex = self.bringInIndex
            self.loadData()
        }
    }
    
    open func loadData() {
        if topBarView.selectIndex == 0 {
            if indexes.count > 0 {
                tableView.reloadData()
                loadStatusView.status = .ok
            } else {
                tableView.reloadData()
                loadStatusView.status = .error("暂无内容")
            }
        } else {
            if pageMarks.count > 0 {
                tableView.reloadData()
                loadStatusView.status = .ok
            } else {
                tableView.reloadData()
                loadStatusView.status = .error("暂无内容")
            }
        }
    }

    public required init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0.6, height: 0)
        view.layer.shadowRadius = 0
        view.layer.shadowColor = QXBookReaderConfigs.barShadowColor.cgColor
        view.backgroundColor = QXBookReaderConfigs.barBackgroundColor
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBarView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topBarView.height)
        tableView.frame = view.bounds
        loadStatusView.frame = view.bounds
    }

    private var _isPresent = true
    private lazy var _coverView: UIButton = {
        let e = UIButton()
        e.backgroundColor = QXBookReaderConfigs.deepMaskColor
        e.addTarget(self, action: #selector(_coverViewClick), for: .touchUpInside)
        return e
    }()
    @objc public func _coverViewClick() {
        dismiss(animated: true, completion: nil)
    }

    private var _selectIndex: QXBookIndex?

}

extension QXBookReaderIndexVc: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if topBarView.selectIndex == 0 {
            return 1
        } else {
            return 1
        }
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if topBarView.selectIndex == 0 {
            return indexes.count
        } else {
            return pageMarks.count
        }
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return QXBookReaderChapterTopBarView.height
    }
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return QXBookReaderUtils.getBottomAppendHeight()
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if topBarView.selectIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QXBookReaderChapterIndexCell", for: indexPath) as! QXBookReaderChapterIndexCell
            let index = indexes[indexPath.row]
            let isSelect: Bool
            if let e = _selectIndex {
                isSelect = e == index
            } else {
                isSelect = false
            }            
            if isSelect {
                cell.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
                cell.titleLabel.textColor = QXBookReaderConfigs.tintColor
            } else {
                cell.titleLabel.font = UIFont.systemFont(ofSize: 16)
                cell.titleLabel.textColor = QXBookReaderConfigs.titleColor
            }
            let isThisLevel0 = index.level == 0
            cell.contentView.backgroundColor = isThisLevel0 ? QXBookReaderConfigs.backgroundLightGrayColor : QXBookReaderConfigs.backgroundColor
            if index.level > 1 {
                cell.offset = 15 * CGFloat(index.level - 1)
            } else {
                cell.offset = 0
            }
            cell.setNeedsLayout()
            cell.titleLabel.text = index.title
            let isNextLevel0 = indexPath.row + 1 < indexes.count - 1 ? (indexes[indexPath.row + 1].level == 0) : false
            if indexPath.row == indexes.count - 1 {
                cell.lineView.isHidden = true
            } else if isThisLevel0 || isNextLevel0 {
                cell.lineView.isHidden = true
            } else {
                cell.lineView.isHidden = false
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QXBookReaderPageMarkCell", for: indexPath) as! QXBookReaderPageMarkCell
            let mark = pageMarks[indexPath.row]
            cell.titleLabel.text = mark.chapterTitle
            cell.contentLabel.text = mark.content
            cell.dateLabel.text = QXBookReaderUtils.getNatureDateString(Date(timeIntervalSince1970: mark.createTime))
            cell.lineView.isHidden = indexPath.row == indexes.count - 1
            return cell
        }
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if topBarView.selectIndex == 0 {
            return QXBookReaderChapterIndexCell.height
        } else {
            return QXBookReaderPageMarkCell.height
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if topBarView.selectIndex == 0 {
            let index = indexes[indexPath.row]
            _selectIndex = index
            tableView.reloadData()
            dismiss(animated: true) {
                self.respondSelectChapter?(index)
            }
        } else {
            let mark = pageMarks[indexPath.row]
            dismiss(animated: true) {
                self.respondSelectPageMark?(mark)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if topBarView.selectIndex == 0 {
            return false
        } else {
            return true
        }
    }
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if topBarView.selectIndex == 0 {
            return nil
        } else {
            return [
                UITableViewRowAction(style: .destructive, title: "删除") { action, indexPath in
                    
                }
            ]
        }
    }
    
}

extension QXBookReaderIndexVc: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
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
            containerView.addSubview(toVc.view)
            _coverView.frame = containerView.bounds
            _coverView.alpha = 0
            toVc.view.frame = CGRect(x: -width, y: 0, width: width, height: containerView.bounds.height)
            UIView.animate(withDuration: 0.3) {
                toVc.view.frame = CGRect(x: 0, y: 0, width: self.width, height: containerView.bounds.height)
                self._coverView.alpha = 1
            } completion: { c in
                transitionContext.completeTransition(c)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self._coverView.alpha = 0
                fromVc.view.frame = CGRect(x: -self.width, y: 0, width: self.width, height: containerView.bounds.height)
            } completion: { c in
                self._coverView.removeFromSuperview()
                fromVc.view.removeFromSuperview()
                transitionContext.completeTransition(c)
            }
        }
    }
}

public class QXBookReaderChapterIndexCell: UITableViewCell {
    
    public static let height: CGFloat = 44
    
    public var offset: CGFloat = 0

    public lazy var titleLabel: UILabel = {
        let e = UILabel()
        e.font = UIFont.systemFont(ofSize: 16)
        return e
    }()
    public lazy var lineView: UIView = {
        let e = UIView()
        e.backgroundColor = QXBookReaderConfigs.breakLineColor
        return e
    }()
        
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(lineView)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 15 + offset, y: 0, width: bounds.width - 15 * 2, height: bounds.height)
        lineView.frame = CGRect(x: 15, y: bounds.height - 0.6, width: bounds.width - 15 * 2, height: 0.6)
    }
    
}

public class QXBookReaderPageMarkCell: UITableViewCell {
    
    public static let height: CGFloat = 100
        
    public lazy var titleLabel: UILabel = {
        let e = UILabel()
        e.font = UIFont.systemFont(ofSize: 16)
        e.textColor = QXBookReaderConfigs.titleColor
        return e
    }()
    public lazy var dateLabel: UILabel = {
        let e = UILabel()
        e.font = UIFont.systemFont(ofSize: 14)
        e.textAlignment = .right
        e.textColor = QXBookReaderConfigs.subTextColor
        return e
    }()
    public lazy var contentLabel: UILabel = {
        let e = UILabel()
        e.font = UIFont.systemFont(ofSize: 12)
        e.textColor = QXBookReaderConfigs.textColor
        e.numberOfLines = 0
        return e
    }()
    
    public lazy var lineView: UIView = {
        let e = UIView()
        e.backgroundColor = QXBookReaderConfigs.breakLineColor
        return e
    }()
        
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(lineView)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 15, y: 0, width: bounds.width - 15 * 2 - 10 - 80, height: 36)
        dateLabel.frame = CGRect(x: bounds.width - 15 - 80, y: 0, width: 80, height: 36)
        contentLabel.frame = CGRect(x: 15, y: 36, width: bounds.width - 15 * 2, height: bounds.height - 36 - 10)
        lineView.frame = CGRect(x: 15, y: bounds.height - 0.6, width: bounds.width - 15 * 2, height: 0.6)
    }
    
}
