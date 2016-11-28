//
//  SAMStockProductInfoController.swift
//  SaleManager
//
//  Created by apple on 16/11/28.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMStockProductInfoController: UITableViewController {

    class func infoVC() -> SAMStockProductInfoController? {
        return UIStoryboard(name: "SAMStockProductInfoController", bundle: nil).instantiateInitialViewController() as? SAMStockProductInfoController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

}
