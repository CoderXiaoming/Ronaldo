//
//  SAMHomeButton.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMHomeButton: UIButton {

    //imageView的高度比例
    let imgHeightScale: CGFloat = 0.6
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //布局imageView
        imageView?.frame.origin.x = 0
        imageView?.frame.origin.y = 0
        imageView?.frame.size.height = frame.height * imgHeightScale
        imageView?.frame.size.width = frame.width
        imageView?.contentMode = UIViewContentMode.center
        
        //布局titleLabel
        titleLabel?.frame.origin.x = 0
        titleLabel?.frame.origin.y = imageView!.frame.maxY
        titleLabel?.frame.size.width = frame.width
        titleLabel?.textAlignment = NSTextAlignment.center
    }

}
