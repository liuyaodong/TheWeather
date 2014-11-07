//
//  CitiesManager.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14/10/27.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import Foundation

protocol CitiesManager {
    var currentCity: String? { get }
    var cities: [String] { get }
    
    var availableCities: [String] { get }
    
    func addCity(city: String)
    func removeCity(city: String)
    func removeCityAtIndex(index: Int)
    func selectCurrentCityAtIndex(index: Int)
    func selectCurrentCity(city: String) -> Bool
    
    func identifierOfCity(city: String) -> String?
    func fetchCities(keywords: String, completionHandler: (results: [String]?) -> ())
}
