//
//  MenuViewController.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14/10/22.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import Foundation

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SlidableViewController, CitiesEditingViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let citiesManager: CitiesManager = CitiesManagerFactory.defaultCitiesManager()
    weak var slideNavigationController: SlideNavigationController?
    
    override func viewDidLoad() {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.citiesManager.cities.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("EditingCities", forIndexPath: indexPath) as UITableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("CityCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel.text = self.citiesManager.cities[indexPath.row - 1]
            
            if self.citiesManager.cities[indexPath.row - 1] == self.citiesManager.currentCity {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
        }
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0 {
            let viewController = UIStoryboard.viewControllerWithType(CitiesEditingViewController.self)
            viewController.citiesManager = self.citiesManager
            viewController.delegate = self
            self.presentViewController(viewController, animated: true, completion: nil)
        } else {
            let viewController = UIStoryboard.viewControllerWithType(ForecastViewController.self)
            viewController.city = self.citiesManager.cities[indexPath.row - 1]
            self.slideNavigationController?.show(viewController, animated: true)
            
        }
    }
    
    // MARK: CitiesEditingViewControllerDelegate
    
    func citiesEditingViewControllerDoneWithEditng(controller: CitiesEditingViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.tableView.reloadData()
    }
    
    func citiesEditingViewController(controller: CitiesEditingViewController, didAddCity city: String) {
        
        self.tableView.reloadData()
        
        let viewController = UIStoryboard.viewControllerWithType(ForecastViewController.self)
        viewController.city = self.citiesManager.currentCity
        self.slideNavigationController?.show(viewController, animated: true)
        
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}