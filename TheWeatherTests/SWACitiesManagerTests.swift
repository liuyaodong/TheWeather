//
//  SWACitiesManagerTests.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14/10/27.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import XCTest

class SWACitiesManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    

    func testCurrentCity() {
        SWACitiesManager.manager().currentCity = "北京"
        XCTAssertEqual(SWACitiesManager.manager().currentCity!, "北京", "")
        
        let manager = SWACitiesManager()
        XCTAssertEqual(manager.currentCity!, "北京", "manager should keep the currentCity when reallocated")
    }
    
    func testCities() {
        SWACitiesManager.manager().cities = ["北京", "上海"]
        XCTAssertEqual(SWACitiesManager.manager().cities!, ["北京", "上海"], "")
        
        let manager = SWACitiesManager()
        XCTAssertEqual(manager.cities!, ["北京", "上海"], "manager should keep the cities when reallocated")
    }
    
    func testCityIdentifier() {
        let identifierOfBeijing = SWACitiesManager.manager().identifierOfCity("北京")!
        XCTAssertEqual(identifierOfBeijing, "101010100", "")
    }
    
    func testInvalidCitiesFetching() {
        let expectation = expectationWithDescription("")
        SWACitiesManager.manager().fetchCities("not a valid city name", completionHandler: {
            (results) in
            if results != nil {
                XCTAssertEqual(countElements(results!), 0, "")
            }
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(1, nil)
    }
    
    func testCitiesFetching() {
        let expectation = expectationWithDescription("")
        SWACitiesManager.manager().fetchCities("京", completionHandler: {
            (results) in
            XCTAssertNotNil(results, "")
            XCTAssertNotNil(find(results!, "北京"), "")
            XCTAssertNotNil(find(results!, "南京"), "")
            XCTAssertNotNil(find(results!, "京山"), "")
            XCTAssertNil(find(results!, "上海"), "")
            XCTAssertEqual(countElements(results!), 3, "")
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(1, nil)
    }

}
