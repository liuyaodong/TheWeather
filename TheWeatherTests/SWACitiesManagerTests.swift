//
//  SWACitiesManagerTests.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14/10/27.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import XCTest

class SWACitiesManagerTests: XCTestCase {
    
    let citiesManager = SWACitiesManager()

    override func setUp() {
        super.setUp()
        NSUserDefaults.resetStandardUserDefaults()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    

    func testCitiesAddAndRemove() {
        citiesManager.addCity("北京")
        XCTAssertEqual(citiesManager.cities, ["北京"])
        XCTAssertEqual(citiesManager.currentCity!, "北京", "")
        
        
        citiesManager.removeCity("北京")
        XCTAssertNil(citiesManager.currentCity, "")
        
    }
    
    func testDuplicateCities() {
        citiesManager.addCity("北京")
        citiesManager.addCity("北京")
        XCTAssertEqual(citiesManager.cities, ["北京"])
    }
    
    func testCurrentCityAndCitiesListCanBeRemembered() {
        
        citiesManager.addCity("北京")
        citiesManager.addCity("上海")
        citiesManager.selectCurrentCity("上海")
        
        let manager = SWACitiesManager()
        XCTAssertEqual(manager.currentCity!, "上海", "manager should keep the currentCity when reallocated")
        XCTAssertEqual(manager.cities, ["北京", "上海"])
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
