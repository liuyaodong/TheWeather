//
//  SWAWeatherCenterTests.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14/10/21.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import UIKit
import XCTest

let CC_SHA1_DIGEST_LENGTH: Int = 20

class SWAWeatherCenterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testWeatherCenterRequestWillFailWithInvalidAreaName() {
        let expectation = expectationWithDescription("")
        let wc = SWAWeatherCenter()
        wc.requestWeatherReport(areaName: "invalid name", completionHandle: {
            (success, reports: [WeatherReport]?) in
            XCTAssertFalse(success, "request should fail")
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(0.5, handler: {
            error in
        })
    }
    
    func testWeatherCenterRequestReturnsValidData() {
        let expectation = expectationWithDescription("")
        let wc = SWAWeatherCenter()
        wc.requestWeatherReport(areaName: "北京", completionHandle: {
            (success, reports: [WeatherReport]?) in
            XCTAssertTrue(success, "")
            XCTAssertEqual(reports!.count, 3, "SWAWeatherCenter API should return 3-days forecast")
            for (index, report) in enumerate(reports!) {
                XCTAssertNotNil(report.weatherDescription, "")

                if report.nightTemperature == nil {
                    XCTFail("")
                }
                if index == 0 {
                    if report.temperature == nil {
                        XCTFail("")
                    }
                    if report.humidity == nil {
                        XCTFail("")
                    }
                    if report.windDirection == nil {
                        XCTFail("")
                    }
                    if report.windPower == nil {
                        XCTFail("")
                    }
                    XCTAssertNotNil(report.updateTime, "")
                }
            }
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(10, handler: {
            error in
        })
    }

}
