//
//  SAMCacheClearer.swift
//  SaleManager
//
//  Created by apple on 17/2/7.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit

///清除沙盒缓存
class SAMCacheClearer: NSObject {
    
    ///清楚该路径内的缓存
    class func clearCaches() {
        // 取出cache文件夹路径
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        
        // 取出文件夹下所有文件数组
        let files = FileManager.default.subpaths(atPath: cachePath)
        
        // 点击确定时开始删除
        for p in files!{
            if (p != "Snapshots")  {
                // 拼接路径
                let path = cachePath.appendingFormat("/\(p)")
                
                // 判断是否可以删除
                if(FileManager.default.fileExists(atPath: path)){
                    // 删除
                    try! FileManager.default.removeItem(atPath: path)
                }
            }
        }
    }
    
    @IBAction func alertAction(sender: UIButton) {
        // 取出cache文件夹路径
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        
        // 取出文件夹下所有文件数组
        let files = FileManager.default.subpaths(atPath: cachePath)
        // 用于统计文件夹内所有文件大小
        var big = Int();
        
        
        // 快速枚举取出所有文件名
        for p in files!{
            // 把文件名拼接到路径中
            let path = cachePath.appendingFormat("/\(p)")
            // 取出文件属性
            let floder = try! FileManager.default.attributesOfItem(atPath: path)
            // 用元组取出文件大小属性
            for (abc,bcd) in floder {
                // 只去出文件大小进行拼接
                if abc == FileAttributeKey.size{
                    big += (bcd as AnyObject).integerValue
                }
            }
        }
        
        // 提示框
        let message = "\(big/(1024*1024))M缓存"
        let alert = UIAlertController(title: "清除缓存", message: message, preferredStyle: .alert)
        
        let alertConfirm = UIAlertAction(title: "确定", style: .default) { (alertConfirm) -> Void in
            // 点击确定时开始删除
            for p in files!{
                // 拼接路径
                let path = cachePath.appendingFormat("/\(p)")
                // 判断是否可以删除
                if(FileManager.default.fileExists(atPath: path)){
                    // 删除
                    try! FileManager.default.removeItem(atPath: path)
                }
            }
        }
        alert.addAction(alertConfirm)
        let cancle = UIAlertAction(title: "取消", style: .cancel) { (cancle) -> Void in
            
        }
        alert.addAction(cancle)
        // 提示框弹出
    }
}
