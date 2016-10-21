//
//  UIViewController+Extension.swift
//  Blocks
//
//  Created by ryan on 10/21/16.
//  Copyright © 2016 pi. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public static weak var topViewController: UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    public static func viewControllerFromStoryboard(name storyboardName: String, identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}
