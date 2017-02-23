//
//  NSMutableArr+Extension.swift
//  SaleManager
//
//  Created by LiuXiaoming on 17/2/22.
//  Copyright © 2017年 YZH. All rights reserved.
//

import Foundation

extension NSMutableArray {

    func compare(modelKeys: [String], searchItems: [String]) -> [Any] {
        
        var andMatchPredicates = [NSPredicate]()
        
        //遍历搜索字符串
        for item in searchItems {
            
            let searchString = NSString(string: item)
            
            var lhs: NSExpression?
            var rhs: NSExpression?
            var matchPredicates = [NSPredicate]()
            
            //遍历匹配模型属性名称
            for modelKey in modelKeys {
                lhs = NSExpression(forKeyPath: modelKey)
                rhs = NSExpression(forConstantValue: searchString)
                let predicate = NSComparisonPredicate(leftExpression: lhs!, rightExpression: rhs!, modifier: .direct, type:
                    .contains, options: .caseInsensitive)
                matchPredicates.append(predicate)
            }
            
            let orMatchPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: matchPredicates)
            andMatchPredicates.append(orMatchPredicate)
        }
        
        let finalCompoundPredicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: andMatchPredicates)
        
        //存储搜索结果
        let arr = filtered(using: finalCompoundPredicate)
        
        return arr
    }
}
