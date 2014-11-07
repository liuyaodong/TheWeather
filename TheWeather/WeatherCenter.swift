//
//  WeatherCenter.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14-8-30.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import Foundation

enum WeatherReportType {
    case Forecast
    case Alarm
    case Realtime
    case Index
}

enum WindDirectionType {
    case NoWind
    case Northeast
    case East
    case Southeast
    case South
    case Southwest
    case West
    case Northwest
    case North
    case WhirlWind
}

struct Temperature {
    static let unit = "°"
    var value: Int
    var description: String {
        return String(value) + Temperature.unit
    }
    init(value: Int) {
        self.value = value
    }
}

extension Temperature: Equatable {}
// MARK: Equatable
func ==(lhs: Temperature, rhs: Temperature) -> Bool {
    return lhs.value == rhs.value
}

extension Temperature: Comparable {}
// MARK: Comparable
func <(lhs: Temperature, rhs: Temperature) -> Bool {
    return lhs.value < rhs.value
}


struct Humidity {
    static let unit = "%"
    var value: Int
    var description: String {
        return String(value) + Humidity.unit
    }
    init(value: Int) {
        self.value = value
    }
}

struct WindPower {
    static let unit = "级"
    var value: Int
    var description: String {
        return String(value) + WindPower.unit
    }
    init(value: Int) {
        self.value = value
    }
}

struct WindDirection {
    var windDirection: WindDirectionType
    var description: String {
        switch windDirection {
        case .NoWind:
			return "无持续风向"
        case .Northeast:
			return "东北风"
        case .East:
			return "东风"
        case .Southeast:
			return "东南风"
        case .South:
			return "南风"
        case .Southwest:
			return "西南风"
        case .West:
			return "西风"
        case .Northwest:
			return "西北风"
        case .North:
			return "北风"
        case .WhirlWind:
			return "旋转风"
        }
    }
}


struct WeatherReport {
    var weatherDescription: String? = nil
    var temperature: Temperature? = nil
    var daytimeTemperature: Temperature? = nil
    var nightTemperature: Temperature? = nil
    var humidity: Humidity? = nil
    var windPower: WindPower? = nil
    var windDirection: WindDirection? = nil
    var updateTime: NSDate? = nil
}

protocol WeatherCenter {
    func requestWeatherReport(#areaName: String, completionHandle: (Bool, [WeatherReport]?) -> ())
}
