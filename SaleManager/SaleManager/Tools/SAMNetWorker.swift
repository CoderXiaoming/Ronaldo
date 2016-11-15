//
//  SAMNetWorker.swift
//  SaleManager
//
//  Created by apple on 16/11/13.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import AFNetworking



class SAMNetWorker: AFHTTPSessionManager {
    
    static let netWorker: SAMNetWorker = {
        //基础路径
//        let baseUrl = NSURL(string: "https://api.weibo.com/")
//        let netWorker = SAMNetWorker(baseURL: baseUrl)
//        let netWorker = SAMNetWorker()
//        //新浪返回的json类型为text/plain 需要手动添加
//        netWorker.responseSerializer.acceptableContentTypes! = NSSet(objects: "application/json", "text/json", "text/javascript", "text/plain") as! Set<String>
        
        return SAMNetWorker()
    }()
    
    /**
     *  对外提供单例的类方法
     */
    class func sharedNetWorker() -> SAMNetWorker {
        return netWorker
    }
    
}
