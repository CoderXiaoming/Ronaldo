//
//  SAMConstant.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

let ScreenW = UIScreen.mainScreen().bounds.width
let ScreenH = UIScreen.mainScreen().bounds.height

let KeyWindow = UIApplication.sharedApplication().keyWindow

let mainColor_green = UIColor(red: 140 / 255.0, green: 213 / 255.0, blue: 82 / 255.0, alpha: 1.0)
let customGrayColor = UIColor(red: 84 / 255.0, green: 84 / 255.0, blue: 84 / 255.0, alpha: 1.0)
let customBlueColor = UIColor(red: 52 / 255.0, green: 152 / 255.0, blue: 219 / 255.0, alpha: 1.0)

/*
 //MARK: - 加载部门列表
 private func loadDepList() {
 SAMNetWorker.sharedNetWorker().GET("getDeptList.ashx", parameters: nil, progress: nil, success: {[unowned self] (Task, Json) in
 let dictArr = Json!["body"] as? [[String: String]]
 
 //判断是否有值
 if (dictArr?.count ?? 0) == 0 {
 return
 }
 
 //添加数据模型
 self.depList.removeAll()
 for dict in dictArr! {
 let depStr = dict["deptName"]
 self.depList.append(depStr!)
 }
 }) { (Task, Error) in
 }
 }
 
 //MARK: - 加载员工列表
 private func loadEmpList() {
 
 SAMNetWorker.sharedNetWorker().GET("getEmployeeList.ashx", parameters: nil, progress: nil, success: {[unowned self] (Task, Json) in
 let dictArr = Json!["body"] as? [[String: String]]
 
 //判断是否有值
 if (dictArr?.count ?? 0) == 0 {
 return
 }
 
 //添加数据模型
 self.empList.removeAll()
 for dict in dictArr! {
 let depStr = dict["employeeName"]
 self.empList.append(depStr!)
 }
 }) { (Task, Error) in
 }
 }
 */
