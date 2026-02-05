/*
 * This is the sample of Dynamsoft Capture Vision Router.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

class PatternTableViewCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: kCellLeftMargin, y: 0, width: self.width, height: kCellHeight))
        label.font = kFont_Regular(kCellTitleFontSize)
        label.textAlignment = .left
        return label
    }()
    
    static func cellHeight() -> CGFloat {
        return kCellHeight
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() -> Void {
        self.backgroundColor = .clear
        self.contentView.addSubview(titleLabel)
    }
    
    func updateUI(with title: String, isSelected: Bool) -> Void {
        self.titleLabel.text = title
        self.contentView.backgroundColor = isSelected == true ? kPatternSelectedColor : kPatternUnselectedColor
    }

}
