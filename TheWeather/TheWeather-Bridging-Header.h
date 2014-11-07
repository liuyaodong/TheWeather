//
//  TheWeather-Bridging-Header.h
//  TheWeather
//
//  Created by Yaodong Liu on 14-7-28.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

#ifndef TheWeather_TheWeather_Bridging_Header_h
#define TheWeather_TheWeather_Bridging_Header_h

#import <CommonCrypto/CommonCrypto.h>

#if DEBUG
#import <UIKit/UIKit.h>
@interface UIView (debug)
- (NSString *)recursiveDescription;
@end
#endif

#endif
