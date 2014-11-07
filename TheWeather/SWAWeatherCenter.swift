//
//  SWAWeatherCenter.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14-8-30.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

// SmartWeatherAPI

// FIXME: input your own app id and private key
let appID = ""
let pk = ""


class SWAWeatherCenter: WeatherCenter {
    
    var weatherReports: [WeatherReport] = [WeatherReport]()
    
    let locationMonitor = LocationMonitor()
    let areaList = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("areaid_list", ofType: "plist")!)
    
    
    func requestWeatherReport(#areaName: String, completionHandle: (Bool, [WeatherReport]?) -> ()) {
        let areaID: String? = self.areaList?.objectForKey(areaName) as String?
        if let aID = areaID {
            
            let forecastType = self.getTypeString(reportType: .Forecast)
            var requestURL = self.generateURLString(aID, type: forecastType, date: NSDate())
            Alamofire.request(.GET, requestURL)
                .responseJSON({
                    (request, response, JSON, error) in
                    if let responseObject = JSON as? [String: AnyObject] {
                        self.weatherReports.removeAll(keepCapacity: true)
                        
                        // Index
//                        let indexDataCollection = SWAIndexData.indexDataCollection(JSON: responseObject)
//                        for index in indexDataCollection {
//                            println("===============")
//                            println("\(index.name): \(index.level) - \(index.content)")
//                            println("===============")
//                        }
                        println("JSON: \(JSON)")
                        
                        // Weather
                        var daytime = false
                        let hour = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitHour, fromDate: NSDate())
                        if hour >= 0 && hour <= 12 {
                            daytime = true
                        }
                        let weatherDataCollection = SWAWeatherData.weatherDataCollection(JSON: responseObject)
                        for weatherData in weatherDataCollection {
                            var report = WeatherReport()
                            if daytime {
                                report.weatherDescription = weatherData.daytimeWeather?.rawValue
                            } else {
                                report.weatherDescription = weatherData.nightWeather?.rawValue
                            }
                            report.daytimeTemperature = weatherData.daytimeTemperature
                            report.nightTemperature = weatherData.nightTemperature
                            self.weatherReports.append(report)
                        }
                    }
                    
                    let realtimeType = self.getTypeString(reportType: .Realtime)
                    var requestURL = self.generateURLString(aID, type: realtimeType, date: NSDate())
                    Alamofire.request(.GET, requestURL)
                        .responseJSON({
                        (request, response, JSON, error) in
                        println("JSON = \(JSON), request = \(request), error = \(error)")
                        if let responseObject = JSON as? [String: AnyObject] {
                            // Realtime
                            if let realtimeData = SWARealtimeData.realtimeData(JSON: responseObject) {
                                if var report = self.weatherReports.first {
                                    if let temp = realtimeData.temperature {
                                        report.temperature = Temperature(value: temp)
                                    }
                                    if let hu = realtimeData.humidity {
                                        report.humidity = Humidity(value: hu)
                                    }
                                    if let wp = realtimeData.windPower {
                                        report.windPower = WindPower(value: wp)
                                    }
                                    report.windDirection = realtimeData.windDirection
                                    report.updateTime = realtimeData.updateTime
                                    self.weatherReports[0] = report
                                }
                            }
                        }
                        completionHandle(true, self.weatherReports)
                    })
                })

        } else {
            completionHandle(false, nil)
        }
    }
    
    private func getTypeString(reportType type: WeatherReportType) -> String {
        switch type {
        case .Forecast:
            return "forecast3d"
        case .Index:
            return "index"
// Alarm service is unavailable
//        case .Alarm:
//            return "alarming"
        case .Realtime:
            return "observe"
        default:
            return "Wrong type"
        }
    }
    
    private func generateURLString(withAreaID: String, type: String, date: NSDate) -> String {
        let host = "http://open.weather.com.cn/data/"
        var requestURL = host + "?"
        requestURL += "areaid=\(withAreaID)&"
        requestURL += "type=\(type)&"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        dateFormatter.locale = NSLocale(localeIdentifier: "zh_CN")
        let dateString = dateFormatter.stringFromDate(date)
        
        requestURL += "date=\(dateString)&"
        let publicKey = requestURL + "appid=\(appID)"
        let key = self.hmac_sha1GivenPrivateKey(publicKey).URLEncode()!
        requestURL += "appid=\((appID as NSString).substringToIndex(6))&"
        requestURL += "key=\(key)"
        
        return requestURL
    }
    
    private func hmac_sha1GivenPrivateKey(input: String) -> String {
        return hmac_sha1(input, pk);
    }
    
    enum SWAWindPower: String {
        case Breeze = "微风"
        case ThreeToFour = "3~4级"
        case FourToFive = "4~5级"
        case FiveToSix = "5~6级"
        case SixToSeven = "6~7级"
        case SevenToEight = "7~8级"
        case EightToNine = "8~9级"
        case NineToTen = "9~10级"
        case TenToEleven = "10~11级"
        case ElevenToTwelve = "11~12级"
        
        static func windPower(fromCode code: Int) -> SWAWindPower? {
            switch code {
            case 0:
                return .Breeze
            case 1:
                return .ThreeToFour
            case 2:
                return .FourToFive
            case 3:
                return .FiveToSix
            case 4:
                return .SixToSeven
            case 5:
                return .SevenToEight
            case 6:
                return .EightToNine
            case 7:
                return .NineToTen
            case 8:
                return .TenToEleven
            case 9:
                return .ElevenToTwelve
            default:
                return nil
            }
        }
    }
    
    enum SWAWeatherType: String {
        case Sunny = "晴"
        case Cloudy = "多云"
        case Overcast = "阴"
        case Shower = "阵雨"
        case Thundershower = "雷阵雨"
        case ThundershowerWithHail = "雷阵雨伴有冰雹"
        case Sleet = "雨夹雪"
        case LightRain = "小雨"
        case ModerateRain = "中雨"
        case HeavyRain = "大雨"
        case Storm = "暴雨"
        case HeavyStorm = "大暴雨"
        case SevereStorm = "特大暴雨"
        case SnowFlurry = "阵雪"
        case LightSnow = "小雪"
        case ModerateSnow = "中雪"
        case HeavySnow = "大雪"
        case Snowstorm = "暴雪"
        case Foggy = "雾"
        case IceRain = "冻雨"
        case Duststorm = "沙尘暴"
        case LightToModerateRain = "小到中雨"
        case ModerateToHeavyRain = "中到大雨"
        case HeavyRainToStorm = "大到暴雨"
        case StormToHeavyStorm = "暴雨到大暴雨"
        case HeavyToSevereStorm = "大暴雨到特大暴雨"
        case LightToModerateSnow = "小到中雪"
        case ModerateToHeavySnow = "中到大雪"
        case HeavySnowToSnowstorm = "大到暴雪"
        case Dust = "浮尘"
        case Sand = "扬沙"
        case Sandstorm = "强沙尘暴"
        case Haze = "霾"
        case Unknown = "无"
        
        static func weatherType(fromCode code: String) -> SWAWeatherType? {
            switch code {
            case "00":
                return .Sunny
            case "01":
                return .Cloudy
            case "02":
                return .Overcast
            case "03":
                return .Shower
            case "04":
                return .Thundershower
            case "05":
                return .ThundershowerWithHail
            case "06":
                return .Sleet
            case "07":
                return .LightRain
            case "08":
                return .ModerateRain
            case "09":
                return .HeavyRain
            case "10":
                return .Storm
            case "11":
                return .HeavyStorm
            case "12":
                return .SevereStorm
            case "13":
                return .SnowFlurry
            case "14":
                return .LightSnow
            case "15":
                return .ModerateSnow
            case "16":
                return .HeavySnow
            case "17":
                return .Snowstorm
            case "18":
                return .Foggy
            case "19":
                return .IceRain
            case "20":
                return .Duststorm
            case "21":
                return .LightToModerateRain
            case "22":
                return .ModerateToHeavyRain
            case "23":
                return .HeavyRainToStorm
            case "24":
                return .StormToHeavyStorm
            case "25":
                return .HeavyToSevereStorm
            case "26":
                return .LightToModerateSnow
            case "27":
                return .ModerateToHeavySnow
            case "28":
                return .HeavySnowToSnowstorm
            case "29":
                return .Dust
            case "30":
                return .Sand
            case "31":
                return .Sandstorm
            case "53":
                return .Haze
            case "99":
                return .Unknown
            default:
                return nil
            }
        }
    }
    
    
    struct SWAWeatherData {
        let timestamp: NSDate
        
        let reportTime: NSDate?
        
        let daytimeWeather: SWAWeatherType?
        let nightWeather: SWAWeatherType?
        
        let daytimeTemperature: Temperature?
        let nightTemperature: Temperature?
        
        let daytimeWindDirection: WindDirection?
        let nightWindDirection: WindDirection?
        
        let daytimeWindPower: SWAWindPower?
        let nightWindPower: SWAWindPower?
        
        
        init(dictionary: [String: String]) {
            
            timestamp = NSDate()
            
            if let timeString = dictionary["f0"] {
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmm"
                reportTime = dateFormatter.dateFromString(timeString)
            }
            
            if let weatherCode = dictionary["fa"] {
                daytimeWeather = SWAWeatherType.weatherType(fromCode: weatherCode)
            }
            if let weatherCode = dictionary["fb"] {
                nightWeather = SWAWeatherType.weatherType(fromCode: weatherCode)
            }
            
            if let temperature = dictionary["fc"]?.toInt() {
                daytimeTemperature = Temperature(value: temperature)
            }
            if let temperature = dictionary["fd"]?.toInt() {
                nightTemperature = Temperature(value: temperature)
            }
            
            if let codeOfWindDirection = dictionary["fe"]?.toInt() {
                daytimeWindDirection = WindDirection.windDirection(fromCode: codeOfWindDirection)
            }
            if let codeOfWindDirection = dictionary["ff"]?.toInt() {
                nightWindDirection = WindDirection.windDirection(fromCode: codeOfWindDirection)
            }
            
            if let codeOfWindPower = dictionary["fg"]?.toInt() {
                daytimeWindPower = SWAWindPower.windPower(fromCode: codeOfWindPower)
            }
            if let codeOfWindPower = dictionary["fh"]?.toInt() {
                nightWindPower = SWAWindPower.windPower(fromCode: codeOfWindPower)
            }
        }
        
        static func weatherDataCollection(JSON rawJSONData: [String: AnyObject]) -> [SWAWeatherData] {
            var weatherDataCollection = [SWAWeatherData]()
            let f: AnyObject? = rawJSONData["f"]
            let f1: AnyObject? = (f as? [String: AnyObject])?["f1"]
            if let threeDayData = f1 as? [[String: String]] {
                for dict in threeDayData {
                    weatherDataCollection.append(SWAWeatherData(dictionary: dict))
                }
            }
            return weatherDataCollection
        }
    }
    
    struct SWARealtimeData {
        let temperature: Int?
        let humidity: Int? // Unit: persent
        let windPower: Int?
        let windDirection: WindDirection?
        let updateTime: NSDate?
        
        init(dictionary: [String: String]) {
            temperature = dictionary["l1"]?.toInt()
            humidity = dictionary["l2"]?.toInt()
            windPower = dictionary["l3"]?.toInt()
            if let codeOfWindDirection = dictionary["l4"]?.toInt() {
                windDirection = WindDirection.windDirection(fromCode: codeOfWindDirection)
            }
            var updated = NSDate()
            let time = dictionary["l7"]
            let hourAndMin = time?.componentsSeparatedByString(":")
            let hour = hourAndMin?.first?.toInt()
            let min = hourAndMin?.last?.toInt()
            if hour != nil && min != nil {
                let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay, fromDate: updated)
                components.hour = hour!
                components.minute = min!
                if let newDate = NSCalendar.currentCalendar().dateFromComponents(components) {
                    updated = newDate
                }
            }
            updateTime = updated
        }
        
        static func realtimeData(JSON rawJSONData: [String: AnyObject]) -> SWARealtimeData? {
            let l: AnyObject? = rawJSONData["l"]
            if let realtimeData = l as? [String: String] {
                return SWARealtimeData(dictionary: realtimeData)
            }
            return nil
        }
    }
    
    struct SWAIndexData {
        let name: String?
        let level: String?
        let content: String?
        let updateTime: String?
        init(dictionary: [String: String]) {
            name = dictionary["i2"]
            level = dictionary["i4"]
            content = dictionary["i5"]
            updateTime = dictionary["i7"]
        }
        
        static func indexDataCollection(JSON rawJSONData: [String: AnyObject]) -> [SWAIndexData] {
            var indexDataCollection = [SWAIndexData]()
            let i: AnyObject? = rawJSONData["i"]
            if let items = i as? [[String: String]] {
                for item in items {
                    indexDataCollection.append(SWAIndexData(dictionary: item))
                }
            }
            return indexDataCollection
        }
    }
}

extension WindDirection {
    static func windDirection(fromCode code: Int) -> WindDirection? {
        switch code {
        case 0:
            return WindDirection(windDirection: .NoWind)
        case 1:
            return WindDirection(windDirection: .Northeast)
        case 2:
            return WindDirection(windDirection: .East)
        case 3:
            return WindDirection(windDirection: .Southeast)
        case 4:
            return WindDirection(windDirection: .South)
        case 5:
            return WindDirection(windDirection: .Southwest)
        case 6:
            return WindDirection(windDirection: .West)
        case 7:
            return WindDirection(windDirection: .Northwest)
        case 8:
            return WindDirection(windDirection: .North)
        case 9:
            return WindDirection(windDirection: .WhirlWind)
        default:
            return nil
        }
    }
}
