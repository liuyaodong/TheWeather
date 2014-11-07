//
//  NSString+URLEncoding.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14/10/21.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import Foundation

extension String {
    func URLEncode() -> String? {
//        let customCharacterSet = NSMutableCharacterSet()
//        customCharacterSet.formUnionWithCharacterSet(NSCharacterSet.alphanumericCharacterSet())
//        customCharacterSet.addCharactersInString(".-_~")
        return self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    }
}