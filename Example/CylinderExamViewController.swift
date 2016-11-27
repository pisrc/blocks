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
                [BConstraint.centerH(label, superview: self), BConstraint.centerV(label, superview: self)])
            addConstraints(
                BConstraintsBuilder(view: imageView, name: "imageView")
                .add(vfs: "H:|[imageView]|", "V:|[imageView]|")
                .constraints)
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
        
        let consts = BConstraintsBuilder(view: cylinderView, name: "cylinderView")
            .add(vfs: "H:|[cylinderView]|", "V:|[cylinderView]|")
            .constraints
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
    public func cylinderView(_ cylinderView: CylinderView, didChangeViewIndex: Int) {
        print("didChangeViewIndex: \(didChangeViewIndex)")
    }
    public func cylinderViewStartIndex(_ cylinderView: CylinderView) -> Int {
        return 7
    }
    
}
