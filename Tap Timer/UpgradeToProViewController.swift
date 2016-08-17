//
//  UpgradeToProViewController.swift
//  Tap Timer
//
//  Created by Simon Barker on 22/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit

//protocol tells primary view controller that user has upgraded to pro
protocol proUpgradeDelegate {
    func upgradedToPro(upgradeSucessful: Bool)
}

class UpgradeToProViewController: UIViewController {

    var delegate: proUpgradeDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.addBackgroundGradient(self.view)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func upgradeToProTapped(sender: AnyObject) {
        isPro = true
        TTDefaultsHelper.upgradeToPro()
        self.delegate?.upgradedToPro(true)
        self.dismissViewControllerAnimated(true, completion: nil)
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
