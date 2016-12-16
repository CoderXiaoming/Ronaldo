//
//  SAMCustomerCollectionCell.swift
//  SaleManager
//
//  Created by apple on 16/11/16.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

protocol SAMCustomerCollectionCellDelegate: NSObjectProtocol {
    func customerCellDidClickEdit()
    func customerCellDidClickVisit()
    func customerCellDidClickPhone()
}

class SAMCustomerCollectionCell: UICollectionViewCell {

    ///代理
    weak var delegate: SAMCustomerCollectionCellDelegate?
    
    ///接收的数据模型
    var customerModel: SAMCustomerModel? {
        didSet{
            //设置 customerLabel
            if customerModel?.CGUnitName != "" {
                customerLabel.text = customerModel?.CGUnitName
            }else {
                customerLabel.text = "---"
            }
            
            //设置 remarkLabel
            if customerModel?.memoInfo != "" {
                remarkLabel.text = customerModel?.memoInfo
            }else {
                remarkLabel.text = "---"
            }
            
            //设置 phoneLabel
            if customerModel?.mobilePhone != "" {
                phoneLabel.text = customerModel?.mobilePhone
            }else {
                phoneLabel.text = "---"
            }
            
            //设置 faxLabel
            if customerModel?.faxNumber != "" {
                faxLabel.text = customerModel?.faxNumber
            }else {
                faxLabel.text = "---"
            }
            
            //设置 telLabel
            if customerModel?.phoneNumber != "" {
                telLabel.text = customerModel?.phoneNumber
            }else {
                telLabel.text = "---"
            }
            
            //设置 addLabel
            var addStr = ""
            if (customerModel?.province != "") && (customerModel?.city != "") {
                addStr = String(format: "(%@/%@)", (customerModel?.province)!, (customerModel?.city)!)
            }else if customerModel?.province != "" {
                addStr = String(format: "（%@）", (customerModel?.province)!)
            }else if customerModel?.city != "" {
                addStr = String(format: "（%@）", (customerModel?.city)!)
            }
            
            if customerModel?.address != "" {
                addStr = addStr + (customerModel?.address)!
            }
            
            if addStr != "" {
                addLabel.text = addStr
            }else {
                addLabel.text = "---"
            }
        }
    }
    
    //MARK: - 初始化操作
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //添加左滑动手势
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SAMCustomerCollectionCell.leftSwipeCell))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        addGestureRecognizer(leftSwipe)
        
        //添加右滑动手势
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SAMCustomerCollectionCell.rightSwipeCell))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        addGestureRecognizer(rightSwipe)
    }
    
    //MARK: - 判断当前是否被选中
    func hasSelected() -> Bool {
        if containterView.backgroundColor!.cgColor == UIColor.white.cgColor {
            return false
        }
        return true
    }
    
    //MARK: - SwipeGesture
    func leftSwipeCell() {
        //当前未被选中，返回
        if  hasSelected() == false {
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.containterView.transform = CGAffineTransform(translationX: -60, y: 0)
        }) 
    }
    func rightSwipeCell() {
        //当前未被选中，返回
        if  hasSelected() == false {
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.containterView.transform = CGAffineTransform.identity
        }) 
    }
    
    
    //MARK: - 点击事件处理
    @IBAction func editBtnClick(_ sender: AnyObject) {
        delegate?.customerCellDidClickEdit()
    }
    @IBAction func visitBtnClick(_ sender: AnyObject) {
        delegate?.customerCellDidClickVisit()
    }
    @IBAction func phoneBtnClick(_ sender: AnyObject) {
        delegate?.customerCellDidClickPhone()
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var containterView: UIView!
    
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var faxLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
}
