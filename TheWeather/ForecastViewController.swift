//
//  ForecastViewController.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14-7-28.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import UIKit


class ForecastViewController: UIViewController, UIScrollViewDelegate, SlidableViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureRangeLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windPowerLabel: UILabel!
    @IBOutlet weak var windDirectionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backgoundImage: UIImageView!
    
    @IBOutlet weak var cell0: ForecastCell!
    @IBOutlet weak var cell1: ForecastCell!
    @IBOutlet weak var cell2: ForecastCell!
    
    @IBOutlet weak var topPaddingConstraint: NSLayoutConstraint!
    
    
    let weatherCenter = WeatherCenterFactory.defaultWeatherCenter()
    let locationMonitor = LocationMonitor()
    
    var city: String?
    var previousUpdateTime: NSDate? = nil
    weak var slideNavigationController: SlideNavigationController?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cityLabel.text = self.city
        
        self.scrollView.addPullToRefreshWithAction({
            if self.city != nil {
                self.refreshViewWithForecast(self.city, completion: {
                    self.scrollView.stopPullToRefresh()
                })
            }
        }, withAnimator: BeatAnimator())
        
        self.scrollView.alpha = 0
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            (notification) in
            if self.previousUpdateTime != nil && NSDate().timeIntervalSinceDate(self.previousUpdateTime!) > 10 * 60 {
                self.refreshViewWithForecast(self.city, completion: {})
            }
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshViewWithForecast(self.city, completion: {})
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var normalizedOffsetY = scrollView.contentOffset.y / 30.0
        if normalizedOffsetY > 1.0 {
            normalizedOffsetY = 1.0
        } else if normalizedOffsetY < 0.0 {
            normalizedOffsetY = 0.0
        }
        self.updateTimeLabel.alpha = 1.0 - normalizedOffsetY
        
    }
    
    private func refreshViewWithForecast(city: String?, completion: () -> ()) {
        if city == nil {
            return
        }
        
        if self.cityLabel != nil {
            self.cityLabel.text = self.city
        }
        
        self.weatherCenter.requestWeatherReport(areaName: city!, completionHandle: {
            (success, weatherReports: [WeatherReport]?) in

            completion()
            
            if (success) {
                if let allReports = weatherReports {
                    let cells = [self.cell0, self.cell1, self.cell2]
                    var day = NSDate()
                    for (index, report) in enumerate(allReports) {
                        if index == 0 {
                            self.temperatureLabel.text = report.temperature?.description
                            self.humidityLabel.text = report.humidity?.description
                            self.windPowerLabel.text = report.windPower?.description
                            self.windDirectionLabel.text = report.windDirection?.description
                            self.weatherLabel.text = report.weatherDescription
                            self.temperatureRangeLabel.text = report.temperatureRange
                            
                            var updateString = ""
                            self.previousUpdateTime = report.updateTime
                            if let updateTime = report.updateTime {
                                let updateInterval = day.timeIntervalSinceDate(updateTime)
                                if updateInterval < 60 * 30 {
                                    updateString = "\(Int(updateInterval / 60))分钟前发布"
                                } else if updateInterval >= 60 * 30 && updateInterval < 60 * 60 {
                                    updateString = "半个小时前发布"
                                } else {
                                    updateString = "\(Int(updateInterval / (60 * 60)))分钟前发布"
                                }
                            }
                            self.updateTimeLabel.text = updateString
                        }
                        cells[index].day = day.dayOfWeek
                        self.cell0.day = "今天"
                        cells[index].weather = report.weatherDescription
                        cells[index].temperature = report.temperatureRange
                        day = day.tomorrow
                    }
                }
                
                let padding = self.containerView.convertPoint(self.cell0.frame.origin, fromView: self.cell0).y
                self.topPaddingConstraint.constant = CGRectGetHeight(self.scrollView.bounds) - padding
                UIView.animateWithDuration(0.23, animations: {
                    self.scrollView.alpha = 0
                    }, completion: {
                        (finished) in
                    UIView.animateWithDuration(0.3, animations: {
                        self.scrollView.alpha = 1
                    })
                })
                
            }
        })
    }
}

extension NSDate {
    
    var dayOfWeek: String {
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "EEEE"
        dateFormater.locale = NSLocale(localeIdentifier: "zh_CN")
        return dateFormater.stringFromDate(self)
    }
    
    var tomorrow: NSDate {
        return NSDate(timeInterval: 24 * 60 * 60, sinceDate: self)
    }
}

extension WeatherReport {
    var temperatureRange: String {
        var temperatureRange = ""
        if let nt = self.nightTemperature {
            if let dt = self.daytimeTemperature {
                if dt > nt {
                    temperatureRange = String(nt.value) + "~" + dt.description + "C"
                } else {
                    temperatureRange = String(dt.value) + "~" + dt.description + "C"
                }
            } else {
                temperatureRange = "夜间最低" + nt.description + "C"
            }
        }
        return temperatureRange
    }
}

