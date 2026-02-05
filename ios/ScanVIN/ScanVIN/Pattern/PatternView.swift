/*
 * This is the sample of Dynamsoft Capture Vision Router.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

class PatternView: UIView, UITableViewDelegate, UITableViewDataSource{
    
    var patternSelectedCompletion: PatternSelectedCompletion?
    
    private var PatternListArray: [VINPattern] = [.barcode, .text]
    
    private var selectedPattern: VINPattern!
    
    private var recordPatternOptionalStateDic: [VINPattern : Bool] = [:]
    
    private lazy var patternTableView: UITableView = {
        let tableView = UITableView.init(frame: self.bounds, style: .plain)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    init(frame: CGRect, selectedPattern: VINPattern) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.selectedPattern = selectedPattern
        handleData()
        setupUI()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func patternHeight() -> CGFloat {
        return kCellHeight * 2
    }

    private func setupUI() -> Void {
        self.addSubview(patternTableView)
    }
    
    private func handleData() -> Void {
        recordPatternOptionalStateDic.removeAll()
        
        for singlePattern in PatternListArray {
            if selectedPattern == singlePattern {
                recordPatternOptionalStateDic[singlePattern] = true
            } else {
                recordPatternOptionalStateDic[singlePattern] = false
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PatternTableViewCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.PatternListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let singlePattern = self.PatternListArray[indexPath.row]
        
        let identifier = PatternTableViewCell.className
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? PatternTableViewCell
        if cell == nil {
            cell = PatternTableViewCell.init(style: .default, reuseIdentifier: identifier)
        }
        
        cell?.updateUI(with: singlePattern.rawValue, isSelected: self.recordPatternOptionalStateDic[singlePattern]!)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let selectedPattern = self.PatternListArray[indexPath.row]
        
        for singlePattern in PatternListArray {
            if selectedPattern == singlePattern {
                recordPatternOptionalStateDic[singlePattern] = true
            } else {
                recordPatternOptionalStateDic[singlePattern] = false
            }
        }
        
        self.selectedPattern = selectedPattern
        self.handleData()
        self.patternTableView.reloadData()
        self.patternSelectedCompletion?(selectedPattern)
    }

}
