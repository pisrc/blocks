//
//  UIView+Extension.swift
//  Blocks
//
//  Created by ryan on 24/11/2016.
//  Copyright © 2016 pi. All rights reserved.
//

import UIKit

extension UIView {
    public func set(child: UIView) {
        
        child.clipsToBounds = true
        
        subviews.forEach { (child) in
            child.removeFromSuperview()
        }
        addSubview(child)
        
        let consts = [NSLayoutConstraint](
            ConstraintsBuilder(view: child, name: "child")
                .set(vfs: "H:|[child]|", "V:|[child]|"))
        removeConstraints(constraints)
        addConstraints(consts)
    }
}
