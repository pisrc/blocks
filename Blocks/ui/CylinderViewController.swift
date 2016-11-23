//
//  CylinderViewController.swift
//  Blocks
//
//  Created by ryan on 23/11/2016.
//  Copyright © 2016 pi. All rights reserved.
//

import UIKit

public enum CylinderBufferIndex {
    case buffer0
    case buffer1
    case buffer2
}

public protocol CylinderViewDelegate: class {
    func cylinderView(bufferFor index: CylinderBufferIndex) -> UIViewController
}

open class CylinderViewController: UIViewController {
    
    weak var delegate: CylinderViewDelegate?
    var scrollView: UIScrollView!
    
    fileprivate var pagesBuffer: [UIViewController]!  // only 3
    fileprivate var leftPage: UIViewController!
    fileprivate var centerPage: UIViewController!
    fileprivate var rightPage: UIViewController!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let delegate = delegate else {
            return
        }
        
        pagesBuffer = [
            delegate.cylinderView(bufferFor: .buffer0),
            delegate.cylinderView(bufferFor: .buffer1),
            delegate.cylinderView(bufferFor: .buffer2)]
        leftPage = pagesBuffer[0]
        centerPage = pagesBuffer[1]
        rightPage = pagesBuffer[2]
        
        scrollView = UIScrollView()
        
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
