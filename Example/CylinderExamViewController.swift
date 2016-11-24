//
//  CylinderExamViewController.swift
//  Blocks
//
//  Created by ryan on 23/11/2016.
//  Copyright © 2016 pi. All rights reserved.
//

import UIKit
import Blocks

class CylinderExamViewController: CylinderViewController {

    let datas = [1,2,3,4,5,6,7,8,9]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cylinderView.delegate = self
    }
    
}

extension CylinderExamViewController: CylinderViewDelegate {
    public func cylinderViewNumberOfPages(_ cylinderView: CylinderView) -> Int {
        return datas.count
    }
    
    public func cylinderView(_ cylinderView: CylinderView, viewAt index: Int) -> UIView {
        let v = UIView()
        if index == 0 {
            v.backgroundColor = UIColor.gray
        } else if index == 1 {
            v.backgroundColor = UIColor.brown
        } else if index == 2 {
            v.backgroundColor = UIColor.cyan
        }
        return v
    }
    
    public func cylinderView(_ cylinderView: CylinderView, didChangeViewIndex: Int) {
        print("didChangeViewIndex: \(didChangeViewIndex)")
    }
    
}
