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
        subviews.forEach { (child) in
            child.removeFromSuperview()
        }
        addSubview(child)
        
        let consts = BConstraintsBuilder(view: child, name: "child")
            .add(vfs: "H:|[child]|", "V:|[child]|")
            .constraints
        addConstraints(consts)
    }
}
