//
//  SAMStringExtension.swift
//  SaleManager
//
//  Created by apple on 16/11/18.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

extension String {
    func stringByTrimmingWhitespace() -> String? {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}
