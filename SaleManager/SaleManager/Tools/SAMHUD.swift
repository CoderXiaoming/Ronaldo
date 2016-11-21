//
//  SAMHUD.swift
//  SaleManager
//
//  Created by apple on 16/11/17.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import MBProgressHUD

///提示信息常规隐藏时间
let SAMHUDNormalDuration = 1.5

class SAMHUD: MBProgressHUD {

    //MARK: - 对外提供的类方法，提示文字信息
    class func showMessage(message: String, superView: UIView, hideDelay: NSTimeInterval, animated: Bool) -> SAMHUD {
        let hud = showHUDAddedTo(superView, animated: animated)
        hud.mode = MBProgressHUDMode.Text;
        hud.labelText = NSLocalizedString(message, comment: "HUD message title")
        hud.hide(true, afterDelay: hideDelay)
        
        return hud
    }
}
