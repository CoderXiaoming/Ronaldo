//
//  SAMComOperationIndicaterView.swift
//  SaleManager
//
//  Created by apple on 16/12/24.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

protocol SAMComOperationIndicaterViewDelegate: NSObjectProtocol {
    func comOperationIndicaterViewDidSelected(index: Int)
}

class SAMComOperationIndicaterView: UIView {

    ///代理
    var delegate: SAMComOperationIndicaterViewDelegate?
    
    ///刚是否点击过，可供代理判断
    var didClicked = false
    
    //MARK: - 对外提供的类工厂方法
    class func instance() -> SAMComOperationIndicaterView {
    
        let view = Bundle.main.loadNibNamed("SAMComOperationIndicaterView", owner: nil, options: nil)![0] as! SAMComOperationIndicaterView
        return view
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //记录数组
        allButtons = [orderManagerButton, forSaleButton, oweButton, saleHistoryButton, customerRankButton, productRankButton]
        
        //设置第一个选中
        orderManagerButton.isSelected = true
        lastSelectedBtn = orderManagerButton
    }
    
    //MARK: - 对外提供的设置indicaterView左间距的方法
    func setIndicaterViewLeftDistance(dicstance: CGFloat) {
        indicaterViewLeadingDistance.constant = dicstance
    }
    
    //MARK: - 对外提供的检查选中按钮的方法
    func checkSelectedIndex(shouldSelectedIndex: Int) {
    
        let button = allButtons![shouldSelectedIndex]
        if !button.isSelected {
            lastSelectedBtn?.isSelected = false
            button.isSelected = true
            lastSelectedBtn = button
        }
    }
    
    //MARK: - 点击事件处理
    @IBAction func orderManageBtnClick(_ sender: SAMImageAboveButton) {
        indicaterViewDidSelected(selectedButton: sender, index: 0)
    }
    @IBAction func forSaleBtnClick(_ sender: SAMImageAboveButton) {
        indicaterViewDidSelected(selectedButton: sender, index: 1)
    }
    @IBAction func oweBtnClick(_ sender: SAMImageAboveButton) {
        indicaterViewDidSelected(selectedButton: sender, index: 2)
    }
    @IBAction func saleHistoryBtnClick(_ sender: SAMImageAboveButton) {
        indicaterViewDidSelected(selectedButton: sender, index: 3)
    }
    @IBAction func customerRankBtnClick(_ sender: SAMImageAboveButton) {
        indicaterViewDidSelected(selectedButton: sender, index: 4)
    }
    @IBAction func productRankBtnClick(_ sender: SAMImageAboveButton) {
        indicaterViewDidSelected(selectedButton: sender, index: 5)
        
    }
    
    ///6个按钮点击集中调用的方法
    fileprivate func indicaterViewDidSelected(selectedButton: SAMImageAboveButton, index: Int) {
        
        didClicked = true
        
        lastSelectedBtn?.isSelected = false
        selectedButton.isSelected = true
        lastSelectedBtn = selectedButton
        
        //调用代理
        delegate?.comOperationIndicaterViewDidSelected(index: index)
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.indicaterViewLeadingDistance.constant = self.perWidth * CGFloat(index)
            self.layoutIfNeeded()
        }) { (_) in
            self.didClicked = false
        }
    }
    
    //MARK: - 属性
    fileprivate var allButtons: [SAMImageAboveButton]?
    
    fileprivate var lastSelectedBtn: SAMImageAboveButton?
    
    fileprivate let animationDuration = 0.4
    
    fileprivate let perWidth = ScreenW / 6
    
    
    //MARK: - XIB链接属性
    @IBOutlet weak var orderManagerButton: SAMImageAboveButton!
    @IBOutlet weak var forSaleButton: SAMImageAboveButton!
    @IBOutlet weak var oweButton: SAMImageAboveButton!
    @IBOutlet weak var saleHistoryButton: SAMImageAboveButton!
    @IBOutlet weak var customerRankButton: SAMImageAboveButton!
    @IBOutlet weak var productRankButton: SAMImageAboveButton!
    
    @IBOutlet weak var indicaterView: UIView!
    
    ///indicaterView左边距离
    @IBOutlet weak var indicaterViewLeadingDistance: NSLayoutConstraint!
    
    
}
