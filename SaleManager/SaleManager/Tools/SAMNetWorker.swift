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
    
    ///全局使用的netWorker单例
    private static var netWorker: SAMNetWorker?{
        didSet{
            loginNetWorker = nil
        }
    }
    
    //MARK: - 对外提供全局使用的单例的类方法
    class func sharedNetWorker() -> SAMNetWorker {
        return netWorker!
    }
    
    //MARK: - 创建全局使用单例的类方法
    class func globalNetWorker(baseURLStr: String) -> SAMNetWorker{
        if netWorker != nil {
            return netWorker!
        }else {
            let URLStr = String(format: "http://%@", baseURLStr)
            let URL = NSURL(string: URLStr)
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.timeoutIntervalForResource = 4.0
            configuration.timeoutIntervalForRequest = 4.0
            netWorker = SAMNetWorker(baseURL: URL!, sessionConfiguration: configuration)
            return netWorker!
        }
    }
    
    ///登录界面用的netWorker
    private static var loginNetWorker: SAMNetWorker? = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 4.0
        configuration.timeoutIntervalForResource = 4.0
        let worker = SAMNetWorker(sessionConfiguration: configuration)
        return SAMNetWorker()
    }()
    //MARK: - 对外提供登录netWorker单例的类方法
    class func sharedLoginNetWorker() -> SAMNetWorker {
        return loginNetWorker!
    }
    
}
