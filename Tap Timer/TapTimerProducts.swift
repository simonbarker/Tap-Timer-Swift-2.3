//
//  TapTimerProducts.swift
//  Tap Timer
//
//  Created by Simon Barker on 03/09/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import Foundation

public struct TapTimerProducts {
    
    private static let Prefix = "com.sbarker.TapTimer."
    
    public static let TapTimerPro = Prefix + "Pro"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [TapTimerProducts.TapTimerPro]
    
    public static let store = IAPHelper(productIds: TapTimerProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(productIdentifier: String) -> String? {
    return productIdentifier.componentsSeparatedByString(".").last
}
