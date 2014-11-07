//
//  LocationMonitorTest.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14-9-10.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation

class LocationMonitorTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCompletionHandleWillBeInvokedAfterAWhile() {
        let locationMonitor: LocationMonitor = LocationMonitor()
        let expectation = expectationWithDescription("get location completion handler")
        locationMonitor.startMonitorWith({
            (country, locality, subLocality, error) in
            XCTAssertNotNil(country, "")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: {
            error in
            println("error: \(error)")
        })
    }
    
    func testMonitorWillReturnMeaningfulValuesWhenLocationsUpdated() {
        let locationMonitor: LocationMonitor = LocationMonitor()
        let expectation = expectationWithDescription("get location completion handler")
        var closesureExecuted = false
        locationMonitor.startMonitorWith({
            (country, locality, subLocality, error) in
            XCTAssertNotNil(country, "")
            XCTAssertNotNil(locality, "")
            XCTAssertNotNil(subLocality, "")
            expectation.fulfill()
        })
        
        locationMonitor.locationManager(locationMonitor.locationManager, didUpdateLocations: [CLLocation(latitude: 39.9139, longitude: 116.3917)])
        waitForExpectationsWithTimeout(1, handler: {
            error in
            println("error: \(error)")
        })

    }


}
