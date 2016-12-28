//
//  SAMQRCoder.h
//  SaleManager
//
//  Created by apple on 16/12/28.
//  Copyright © 2016年 YZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMBase64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>

@interface SAMQRCoder : NSObject

+ (NSString*)encryptWithContent:(NSString*)content type:(CCOperation)type key:(NSString*)aKey;

@end
