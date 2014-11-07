//
//  WeatherCenterFactory.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14/11/7.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import Foundation

class WeatherCenterFactory {
    class func defaultWeatherCenter() -> WeatherCenter {
//        return SWAWeatherCenter()
        return FakeWeatherCenter()
    }
}