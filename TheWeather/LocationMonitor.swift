//
//  LocationMonitor.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14-9-7.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import Foundation
import CoreLocation

class LocationMonitor: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var country = ""
    var locality = ""
    var subLocality = ""
    var placeResolvedClosure: ((String?, String?, String?, NSError!) -> ())?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    func startMonitorWith(completionHandler: ((String?, String?, String?, NSError!) -> ())?) {
        self.placeResolvedClosure = completionHandler
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("location manager failed: \(error)")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("stopUpdatingLocation")
        manager.stopUpdatingLocation()
        if let currentLocation = (locations as NSArray).firstObject as? CLLocation {
            let ceo = CLGeocoder()
            ceo.reverseGeocodeLocation(currentLocation, completionHandler: {
                (placemarks, error) in
                if let placeResolveError = error {
                    println("Error: \(placeResolveError)")
                    self.placeResolvedClosure?(nil, nil, nil, error)
                }
                
                if let placemark = placemarks.first as? CLPlacemark {
                    println("original: country:\(placemark.country), locality: \(placemark.locality), sublocality: \(placemark.subLocality)")
                    self.country = placemark.country
                    self.locality = placemark.locality
                    self.subLocality = placemark.subLocality
                    self.placeResolvedClosure?(placemark.country, placemark.locality, placemark.subLocality, nil)
                }
            })
        }
        
    }
}
