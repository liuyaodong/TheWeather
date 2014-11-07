//
//  CitiesEditingViewController.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14/10/27.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import Foundation

protocol CitiesEditingViewControllerDelegate: class {
    func citiesEditingViewControllerDoneWithEditng(controller: CitiesEditingViewController)
    func citiesEditingViewController(controller: CitiesEditingViewController, didAddCity city: String)
}

class CitiesEditingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CitiesSearchViewControllerDelegate {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var citiesManager: CitiesManager!
    weak var delegate: CitiesEditingViewControllerDelegate?
    
    override func viewDidLoad() {
        self.tableView.editing = true;
        self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func addCity(sender: UIBarButtonItem) {
        let viewController = UIStoryboard.viewControllerWithType(CitiesSearchViewController.self)
        viewController.delegate = self
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // MARK: CitiesSearchViewControllerDelegate
    
    func citiesSearchViewController(viewController: CitiesSearchViewController, didSelectCity city: String) {
        
        self.citiesManager.addCity(city)
        self.citiesManager.selectCurrentCity(city)
        
        self.delegate?.citiesEditingViewController(self, didAddCity: city)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func citiesSearchViewControllerDidClose(viewController: CitiesSearchViewController) {
        if self.citiesManager.cities.count > 0 {
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            UIAlertView(title: nil, message: "请选择一个城市", delegate: nil, cancelButtonTitle: "我知道了").show()
        }
    }
    
    // MARK: Button Action
    
    @IBAction func doneWithEditing(sender: UIBarButtonItem) {
        self.delegate?.citiesEditingViewControllerDoneWithEditng(self)
    }
    
    // MARK: UITableView Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.citiesManager.cities.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditingCityCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = self.citiesManager.cities[indexPath.row]
        return cell
    }

    // MARK: UITableView Delegate
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.citiesManager.removeCityAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            if self.citiesManager.cities.count == 0 {
                let viewController = UIStoryboard.viewControllerWithType(CitiesSearchViewController.self)
                viewController.delegate = self
                self.presentViewController(viewController, animated: true, completion: nil)
            }
        }
    }
    

}