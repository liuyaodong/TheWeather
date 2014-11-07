//
//  CryptoUtilities.swift
//
//  Created by Yaodong Liu on 14-8-30.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import Foundation

/*
* #import <CommonCrypto/CommonCrypto.h>
*/
func hmac_sha1(input: String, privateKey: String) -> String {
    var output = ""
    if let data = input.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
        if let pkData = privateKey.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            if let outputData = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH)) {
                let resultBytes = UnsafeMutablePointer<CUnsignedChar>(outputData.mutableBytes)
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), pkData.bytes, UInt(pkData.length), data.bytes, UInt(data.length), resultBytes)
                output = outputData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            }
        }
    }
    return output
}