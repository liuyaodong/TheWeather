//
//  ContainerViewController.swift
//  TheWeather
//
//  Created by Yaodong Liu on 14/10/22.
//  Copyright (c) 2014年 liuyaodong. All rights reserved.
//

import Foundation
import QuartzCore

protocol SlideNavigationController : class {
    func show<T: SlidableViewController where T: UIViewController>(viewController: T, animated: Bool)
    func slideToRight(animated: Bool)
    func slideToLeft(animated: Bool)
}

protocol SlidableViewController : class {
    weak var slideNavigationController: SlideNavigationController? { get set }
}

extension UIStoryboard {
    class func viewControllerWithType<T: UIViewController>(viewControllerClass: T.Type) -> T {
        let className = viewControllerClass.description().componentsSeparatedByString(".").last!
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(className) as T
    }
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
}


class ContainerViewController: UIViewController, UIGestureRecognizerDelegate, SlideNavigationController, CitiesSearchViewControllerDelegate {

    @IBOutlet weak var containerView: UIView!
    
    let menuWidth: CGFloat = 200
    let slideAnimationDuration: CGFloat = 0.4
    let citiesManager = CitiesManagerFactory.defaultCitiesManager()
    
    var contentViewController: UIViewController!
    
    lazy var menuViewController: UIViewController = {
        let viewController = UIStoryboard.viewControllerWithType(MenuViewController.self)
        viewController.slideNavigationController = self
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewController = self.childViewControllers.first as ForecastViewController
        self.contentViewController = viewController
        
        if self.citiesManager.currentCity != nil {
            viewController.slideNavigationController = self
            viewController.city = self.citiesManager.currentCity!
            self.setupContentViewController(self.contentViewController)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.citiesManager.currentCity == nil {
            let citiesSearchViewController = UIStoryboard.viewControllerWithType(CitiesSearchViewController.self)
            citiesSearchViewController.delegate = self
            self.presentViewController(citiesSearchViewController, animated: true, completion: nil)
        }
    }
    
    
    private func setupContentViewController(viewController: UIViewController) {
        // Add gestures
        viewController.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector("panned:")))
        viewController.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("tapped:")))
        
        // Add drop shadow
        viewController.view.layer.shadowPath = UIBezierPath(rect: viewController.view.bounds).CGPath
        viewController.view.layer.shadowColor = UIColor.blackColor().CGColor
        viewController.view.layer.shadowOpacity = 0.8
        viewController.view.layer.shadowOffset = CGSizeMake(-0.5, 2)
        viewController.view.layer.shadowRadius = 6;
    }
    
    // MARK: SlideNavigationController Protocol
    
    func show<T : SlidableViewController where T: UIViewController>(viewController: T, animated: Bool) {
        
        viewController.slideNavigationController = self
        
        if self.contentViewController?.parentViewController != nil {
            self.contentViewController.removeFromParentViewController()
        }
        
        let previousView = self.contentViewController.view
        self.contentViewController = viewController
        self.addChildViewController(viewController)
        self.containerView.addSubview(self.contentViewController.view)
        
        if previousView.superview != nil {
            self.contentViewController.view.frame = previousView.frame
            previousView.removeFromSuperview()
        }
        
        self.setupContentViewController(viewController)
        
        self.slideToLeft(animated)
    }

    func slideToRight(animated: Bool) {
        if (self.contentViewController.view.frame.origin.x >= self.menuWidth) {
            return
        }
        
        let changeFrame: () -> () = {
            var frame = self.contentViewController.view.frame
            frame.origin.x = self.menuWidth
            self.contentViewController.view.frame = frame
        }
        
        if animated {
            let duration: Double = Double(self.slideAnimationDuration * (self.menuWidth - self.contentViewController.view.frame.origin.x) / self.menuWidth)
            self.view.userInteractionEnabled = false
            UIView.animateWithDuration(duration, animations: changeFrame, completion: {
                (finished) in
                self.view.userInteractionEnabled = true
            })
        } else {
            changeFrame()
        }
    }
    
    func slideToLeft(animated: Bool) {
        
        if (self.contentViewController.view.frame.origin.x <= 0) {
            return
        }
        
        let changeFrame: () -> () = {
            var frame = self.contentViewController.view.frame
            frame.origin.x = 0
            self.contentViewController.view.frame = frame
        }
        
        if animated {
            let duration: Double = Double(self.slideAnimationDuration * self.contentViewController.view.frame.origin.x / self.menuWidth)
            self.view.userInteractionEnabled = false
            UIView.animateWithDuration(duration, animations: changeFrame, completion: {
                (finished) in
                self.view.userInteractionEnabled = true
            })
        } else {
            changeFrame()
        }
    }
    
    // MARK: Gesture Actions

    internal func panned(gesture: UIPanGestureRecognizer) {
        
        var endedOrCancelled = false
        var needsAnimation = true
        
        if gesture.state == UIGestureRecognizerState.Began {
            
            self.addChildViewController(self.menuViewController)
            self.containerView.insertSubview(self.menuViewController.view, belowSubview: self.contentViewController.view)
            
        } else if gesture.state == UIGestureRecognizerState.Changed {
            
            let translationX = gesture.translationInView(self.view).x
            var frame = self.contentViewController.view.frame
            frame.origin.x += translationX
            if CGRectGetMinX(frame) >= menuWidth {
                frame.origin.x = menuWidth
            }
            
            if CGRectGetMinX(frame) <= 0 {
                frame.origin.x = 0
            }
            self.contentViewController.view.frame = frame
            
            gesture.setTranslation(CGPointZero, inView: self.view)
            
        } else if gesture.state == UIGestureRecognizerState.Ended {
            endedOrCancelled = true
        } else if gesture.state == UIGestureRecognizerState.Cancelled {
            endedOrCancelled = true
            needsAnimation = false
        }
        
        if endedOrCancelled {
            let velocity = gesture.velocityInView(self.containerView)
            if velocity.x > 0 {
                self.slideToRight(needsAnimation)
            } else {
                self.slideToLeft(needsAnimation)
            }
        }
        
    }
    
    internal func tapped(gesture: UITapGestureRecognizer) {
        self.slideToLeft(true)
    }
    
    // MARK: CitiesSearchViewControllerDelegate
    func citiesSearchViewController(viewController: CitiesSearchViewController, didSelectCity city: String) {
        
        self.citiesManager.addCity(city)
        self.citiesManager.selectCurrentCityAtIndex(0)
        
        self.dismissViewControllerAnimated(true, completion: {
            let viewController = UIStoryboard.viewControllerWithType(ForecastViewController.self)
            viewController.city = city
            self.show(viewController, animated: true)
        })
    }
    
    func citiesSearchViewControllerDidClose(viewController: CitiesSearchViewController) {
        UIAlertView(title: nil, message: "请选择一个城市", delegate: nil, cancelButtonTitle: "我知道了").show()
    }
}