//
//  SAMProductInfo.swift
//  SaleManager
//
//  Created by apple on 16/11/11.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMProductInfo: NSObject {
    
    init(pictureN: UIImage?, nameN: String?, pishuN: Double, mishuN: Double) {
        picture = pictureN
        name = nameN
        pishu = pishuN
        mishu = mishuN
    }
    
    var picture: UIImage?
    var name: String?
    var pishu: Double = 0.0
    var mishu: Double = 0.0
    var moreInfo: [SAMProductInfo]?
}
