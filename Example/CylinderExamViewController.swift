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
        
        
    }
    
}

extension CylinderViewController: CylinderViewDelegate {
    public func cylinderView(bufferFor index: CylinderBufferIndex) -> UIViewController {
        switch index {
        case .buffer0:
            return UIViewController.viewController(fromStoryboard: "Main", identifier: "number")
        case .buffer1:
            return UIViewController.viewController(fromStoryboard: "Main", identifier: "number")
        case .buffer2:
            return UIViewController.viewController(fromStoryboard: "Main", identifier: "number")
        }
    }
}
