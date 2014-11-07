//
//  ForecastCell.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14-10-17.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import UIKit

class ForecastCell: UIView {
    let dayLabel = UILabel()
    let weatherLabel = UILabel()
    let temperatureLabel = UILabel()
    
    var day: String? {
        get {
            return dayLabel.text
        }
        set {
            dayLabel.text = newValue
        }
    }
    
    var weather: String? {
        get {
            return weatherLabel.text
        }
        set {
            weatherLabel.text = newValue
        }
    }
    
    var temperature: String? {
        get {
            return temperatureLabel.text
        }
        set {
            temperatureLabel.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupForecastCell()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupForecastCell()
    }
    
    private func setupForecastCell() {
        addSubview(dayLabel)
        dayLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        dayLabel.font = UIFont.systemFontOfSize(16.0)
        addConstraint(NSLayoutConstraint(item: dayLabel,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self, attribute: NSLayoutAttribute.Left,
            multiplier: 1, constant: 8))
        addConstraint(NSLayoutConstraint(item: dayLabel,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self, attribute: NSLayoutAttribute.CenterY,
            multiplier: 1, constant: 0))
        
        addSubview(weatherLabel)
        weatherLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        weatherLabel.font = UIFont.systemFontOfSize(16.0)
        addConstraint(NSLayoutConstraint(item: weatherLabel,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self, attribute: NSLayoutAttribute.CenterX,
            multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: weatherLabel,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self, attribute: NSLayoutAttribute.CenterY,
            multiplier: 1, constant: 0))
        
        addSubview(temperatureLabel)
        temperatureLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        temperatureLabel.font = UIFont.systemFontOfSize(16.0)
        addConstraint(NSLayoutConstraint(item: temperatureLabel,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self, attribute: NSLayoutAttribute.Right,
            multiplier: 1, constant: -8))
        addConstraint(NSLayoutConstraint(item: temperatureLabel,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self, attribute: NSLayoutAttribute.CenterY,
            multiplier: 1, constant: 0))
    }
}