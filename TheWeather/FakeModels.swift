//
//  FakeModels.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14/11/7.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import Foundation

class FakeCitiesManager: CitiesManager {
    class func manager() -> FakeCitiesManager {
        struct SharedManager {
            static let manager = FakeCitiesManager()
        }
        return SharedManager.manager;
    }
    
    private let areaList: [String: String] = [
        "北京" : "beijing",
        "上海" : "shanghai",
        "深圳" : "shenzhen",
        "阿克苏" : "akesu",
        "广州" : "guangzhou",
    ]
    
    private var managedCities: NSMutableOrderedSet = {
        if let cities = NSUserDefaults.standardUserDefaults().arrayForKey("cities") {
            return NSMutableOrderedSet(array: cities)
        }
        return NSMutableOrderedSet()
        }()
    
    private var currentCityIndex: Int = NSUserDefaults.standardUserDefaults().integerForKey("currentCityIndex")
    
    var currentCity: String? {
        get {
            if self.managedCities.count == 0 {
                return nil
            }
            
            if self.currentCityIndex >= self.managedCities.count {
                self.currentCityIndex = 0
            }
            
            return (self.managedCities.objectAtIndex(self.currentCityIndex) as String)
        }
    }
    
    var cities: [String] {
        get {
            return self.managedCities.array as [String]
        }
    }
    
    var availableCities: [String] {
        return Array(self.areaList.keys)
    }
    
    func addCity(city: String) {
        self.managedCities.addObject(city)
        NSUserDefaults.standardUserDefaults().setObject(self.cities, forKey: "cities")
    }
    
    func removeCity(city: String) {
        self.managedCities.removeObject(city)
        NSUserDefaults.standardUserDefaults().setObject(self.cities, forKey: "cities")
    }
    
    func removeCityAtIndex(index: Int) {
        if index >= 0 && self.managedCities.count > index {
            self.managedCities.removeObjectAtIndex(index)
        }
    }
    
    func selectCurrentCityAtIndex(index: Int) {
        if index >= 0 && self.managedCities.count > index {
            self.currentCityIndex = index
            NSUserDefaults.standardUserDefaults().setInteger(self.currentCityIndex, forKey: "currentCityIndex")
        }
    }
    
    func selectCurrentCity(city: String) -> Bool {
        let index = self.managedCities.indexOfObject(city)
        if index != NSNotFound {
            self.selectCurrentCityAtIndex(index)
            return true
        }
        return false
    }
    
    
    func identifierOfCity(city: String) -> String? {
        return self.areaList[city]
    }
    
    func fetchCities(keywords: String, completionHandler: (results: [String]?) -> ()) {
        let predicate: NSPredicate? = NSPredicate(format: "SELF contains %@", keywords)
        if predicate != nil {
            let r = self.areaList.keys.filter{ predicate!.evaluateWithObject($0) }.array
            completionHandler(results: r)
        } else {
            completionHandler(results: nil)
        }
    }
}

class FakeWeatherCenter: WeatherCenter {
    
    
    let locationMonitor = LocationMonitor()
    
    func requestWeatherReport(#areaName: String, completionHandle: (Bool, [WeatherReport]?) -> ()) {
        
        var weatherReports: [WeatherReport] = [WeatherReport]()
        for i in 0..<3 {
            var weatherReport = WeatherReport()
            weatherReport.weatherDescription = "晴"
            weatherReport.temperature = Temperature(value: Int(arc4random_uniform(3) + 16))
            weatherReport.daytimeTemperature = Temperature(value: Int(arc4random_uniform(3) + 19))
            weatherReport.nightTemperature = Temperature(value: Int(arc4random_uniform(4) + 12))
            weatherReport.humidity = Humidity(value: Int(arc4random_uniform(3) + 49))
            weatherReport.windPower = WindPower(value: Int(arc4random_uniform(3)))
            weatherReport.windDirection = WindDirection.windDirection(fromCode: Int(arc4random_uniform(9)))
            weatherReports.append(weatherReport)
        }
        
        completionHandle(true, weatherReports)

    }
}
