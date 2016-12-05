//
//  CylinderExamViewController.swift
//  Blocks
//
//  Created by ryan on 23/11/2016.
//  Copyright © 2016 pi. All rights reserved.
//

import UIKit
import Blocks
import Cylinder

class CylinderExamViewController: UIViewController {
    
    class NumberView: UIView {
        var label: UILabel!
        var imageView: UIImageView!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = UIColor.yellow
            
            label = UILabel()
            imageView = UIImageView(image: UIImage(named: "pomegranate"))
            imageView.contentMode = .scaleAspectFit
            
            addSubview(imageView)
            addSubview(label)
            
            addConstraints(
                [Constraint.centerH(label, superview: self), Constraint.centerV(label, superview: self)])
            addConstraints(
                [NSLayoutConstraint](ConstraintsBuilder(view: imageView, name: "imageView")
                    .set(vfs: "H:|[imageView]|")
                    .set(vfs: "V:|[imageView]|")))
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var cylinderView: CylinderView!
    let datas = [1,2,3,4,5,6,7,8,9]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        cylinderView = CylinderView()
        cylinderView.delegate = self
        view.addSubview(cylinderView)
        
        let builder = ConstraintsBuilder(view: cylinderView, name: "cylinderView")
            .set(vfs: "H:|[cylinderView]|")
            .set(vfs: "V:|[cylinderView]|")
        let consts = [NSLayoutConstraint](builder)
        view.addConstraints(consts)
    }
}

extension CylinderExamViewController: CylinderViewDelegate {
    public func cylinderViewNumberOfPages(_ cylinderView: CylinderView) -> Int {
        return datas.count
    }
    public func cylinderView(_ cylinderView: CylinderView, viewAt index: Int) -> UIView {
        
        let v = NumberView()
        v.label.text = "\(index)"
        v.label.sizeToFit()
        return v
    }
    public func cylinderView(_ cylinderView: CylinderView, didChange view: UIView) {
        
    }
    public func cylinderViewStartIndex(_ cylinderView: CylinderView) -> Int {
        return 7
    }
    
}
