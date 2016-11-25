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
        
        guard let vc = UIViewController.viewController(fromStoryboard: "Main", identifier: "number") as? NumberViewController else {
            return UIView()
        }
        vc.number = index
        return vc.view
    }
    
    public func cylinderView(_ cylinderView: CylinderView, didChangeViewIndex: Int) {
        print("didChangeViewIndex: \(didChangeViewIndex)")
    }
    
    public func cylinderViewStartIndex(_ cylinderView: CylinderView) -> Int {
        return 7
    }
    
}
