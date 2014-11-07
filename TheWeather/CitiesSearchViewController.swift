//
//  CitiesSearchViewController.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14/10/31.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import Foundation

protocol CitiesSearchViewControllerDelegate {
    func citiesSearchViewController(viewController: CitiesSearchViewController, didSelectCity city: String);
    func citiesSearchViewControllerDidClose(viewController: CitiesSearchViewController);
}

class CitiesSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: CitiesSearchViewControllerDelegate?
    
    private var sections: [[String]] = []
    
    private class IndexedCities {
        
        class func sharedInstance() -> IndexedCities {
            struct SharedInstance {
                static let sharedIndexedCities = IndexedCities()
            }
            return SharedInstance.sharedIndexedCities
        }
        
        private var indexedCities: [([String])]?
        
        deinit {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        
        func indexCitiesWithCompletionHandler(completion: (indexedCities: [[String]]) -> ()) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                if self.indexedCities == nil {
                    let cities = CitiesManagerFactory.defaultCitiesManager().availableCities
                    let sectionTitlesCount = UILocalizedIndexedCollation.currentCollation().sectionTitles.count
                    self.indexedCities = [[String]](count: sectionTitlesCount, repeatedValue: [])
                    let selector: Selector = "self"
                    
                    let sortedCities = UILocalizedIndexedCollation.currentCollation().sortedArrayFromArray(cities, collationStringSelector: selector) as [String]
                    
                    for city in sortedCities {
                        let sectionNumber = UILocalizedIndexedCollation.currentCollation().sectionForObject(city, collationStringSelector: selector)
                        self.indexedCities![sectionNumber].append(city)
                    }
                    
                    NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidReceiveMemoryWarningNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
                        (notification) in
                        self.indexedCities = nil
                    })
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    completion(indexedCities: self.indexedCities!)
                })
            })
        }
        
    }
    
    override func viewDidLoad() {
        self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        IndexedCities.sharedInstance().indexCitiesWithCompletionHandler({
            (indexedCities) in
            self.sections = indexedCities
            self.tableView.reloadData()
        })
    }
    
    @IBAction func closed(sender: UIBarButtonItem) {
        self.delegate?.citiesSearchViewControllerDidClose(self)
    }
    
    // MARK: UITableView Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchableCityCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = self.sections[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return UILocalizedIndexedCollation.currentCollation().sectionTitles[section] as? String
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return UILocalizedIndexedCollation.currentCollation().sectionTitles
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return UILocalizedIndexedCollation.currentCollation().sectionForSectionIndexTitleAtIndex(index)
    }
    
    // MARK: UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.citiesSearchViewController(self, didSelectCity: self.sections[indexPath.section][indexPath.row])
    }
    
}