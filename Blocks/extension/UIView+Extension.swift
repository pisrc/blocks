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
        
        let builder = ConstraintsBuilder()
            .set(view: child, name: "child")
            .set(vfs: "H:|[child]|", "V:|[child]|")
        let consts = [NSLayoutConstraint](builder)
        addConstraints(consts)
    }
    
    public func startZRotation(duration: CFTimeInterval = 1, repeatCount: Float = Float.infinity, clockwise: Bool = true)
    {
        if layer.animation(forKey: "transform.rotation.z") != nil {
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        let direction = clockwise ? 1.0 : -1.0
        animation.toValue = NSNumber(value: M_PI * 2 * direction)
        animation.duration = duration
        animation.isCumulative = true
        animation.repeatCount = repeatCount
        self.layer.add(animation, forKey:"transform.rotation.z")
    }
    
    public func stopZRotation()
    {
        self.layer.removeAnimation(forKey: "transform.rotation.z")
    }
}
