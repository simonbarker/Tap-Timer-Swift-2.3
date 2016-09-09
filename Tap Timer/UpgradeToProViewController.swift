//
//  UpgradeToProViewController.swift
//  Tap Timer
//
//  Created by Simon Barker on 22/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit
import StoreKit

//protocol tells primary view controller that user has upgraded to pro
protocol proUpgradeDelegate {
    func upgradedToPro(upgradeSucessful: Bool)
}

class UpgradeToProViewController: UIViewController {

    var delegate: proUpgradeDelegate? = nil
    var products = [SKProduct]()
    @IBOutlet var upgradePriceLabel: UILabel!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.addBackgroundGradient(self.view)
        
        coverWithActivityIndicator()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handlePurchaseNotification(_:)),
                                                         name: IAPHelper.IAPHelperPurchaseNotification,
                                                         object: nil)
        reload()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func coverWithActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor.flatGrayColorDark()
        Helper.addBackgroundGradient(activityIndicator)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func reload() {
        products = []
        
        TapTimerProducts.store.requestProducts{success, products in
            if success {
                self.products = products!
                
                //self.tableView.reloadData()
                print(products)
                
                for product in products! {
                    
                    NSNumberFormatter.setDefaultFormatterBehavior(.Behavior10_4)
                    let numberFormatter = NSNumberFormatter()
                    numberFormatter.numberStyle = .CurrencyStyle
                    numberFormatter.locale = product.priceLocale
                    
                    let formattedPrice = numberFormatter.stringFromNumber(product.price)
                    
                    self.upgradePriceLabel.text = formattedPrice!
                }
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
            }
            
            //self.refreshControl?.endRefreshing()
        }
    }
    
    func restoreTapped(sender: AnyObject) {
        TapTimerProducts.store.restorePurchases()
    }
    
    func handlePurchaseNotification(notification: NSNotification) {
        isPro = true
        TTDefaultsHelper.upgradeToPro()
        self.delegate?.upgradedToPro(true)
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func upgradeToProTapped(sender: AnyObject) {
        
        //TapTimerProducts.store.buyProduct(products[0])
        
        
        //remove before submitting to app store
        isPro = true
        TTDefaultsHelper.upgradeToPro()
        self.delegate?.upgradedToPro(true)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func restoreButtonTapped(sender: AnyObject) {
        print("restore pressed")
        TapTimerProducts.store.restorePurchases()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
