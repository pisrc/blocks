//
//  Cylinder.swift
//  Blocks
//
//  Created by pi on 23/11/2016.
//  Copyright © 2016 pi. All rights reserved.
//

import UIKit

@objc
public protocol CylinderViewDelegate: class {
    func cylinderViewNumberOfPages(_ cylinderView: CylinderView) -> Int
    @objc optional func cylinderView(_ cylinderView: CylinderView, viewAt index: Int) -> UIView
    @objc optional func cylinderView(_ cylinderView: CylinderView, didChangeViewIndex: Int)
}

public class CylinderView: UIView, UIScrollViewDelegate {
    
    private var scrollView: UIScrollView!
    
    public var child1: UIView!
    public var child2: UIView!
    public var child3: UIView!
    
    private var index = 0
    private var currentPage: Int{
        return Int((scrollView.contentOffset.x + (0.5 * scrollView.frame.size.width)) / scrollView.frame.size.width) + 1
    }
    
    public weak var delegate: CylinderViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.isDirectionalLockEnabled = true
        
        child1 = UIView()
        child2 = UIView()
        child3 = UIView()
        scrollView.addSubview(child1)
        scrollView.addSubview(child2)
        scrollView.addSubview(child3)
        
        addSubview(scrollView)
        
        child1.backgroundColor = UIColor.red
        child2.backgroundColor = UIColor.green
        child3.backgroundColor = UIColor.blue
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        scrollView.frame = rect
        scrollView.contentSize = CGSize(width: rect.width * 3, height: rect.height)
        
        child1.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        child2.frame = CGRect(x: rect.width, y: 0, width: rect.width, height: rect.height)
        child3.frame = CGRect(x: rect.width * 2, y: 0, width: rect.width, height: rect.height)
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        switch currentPage {
        case 1:
            centering()
        case 2:
            break
        case 3:
            centering()
        default:
            break
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.cylinderView?(self, didChangeViewIndex: currentPage - 1)
    }
    
    fileprivate func centering() {
        setChilds(start: index)
        scrollView.contentOffset = CGPoint(x: frame.width, y: 0)
    }
    
    fileprivate func setChilds(start index: Int) {
        
        if let child = delegate?.cylinderView?(self, viewAt: index) {
            child1.set(child: child)
        }
        
        if let child = delegate?.cylinderView?(self, viewAt: index + 1) {
            child2.set(child: child)
        }
        
        if let child = delegate?.cylinderView?(self, viewAt: index + 2) {
            child3.set(child: child)
        }
    }
}

open class CylinderViewController: UIViewController {
    
    public var cylinderView: CylinderView!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        cylinderView = CylinderView()
        view.addSubview(cylinderView)
        
        let consts = BConstraintsBuilder(view: cylinderView, name: "cylinderView")
            .add(vfs: "H:|[cylinderView]|", "V:|[cylinderView]|")
            .constraints
        view.addConstraints(consts)
    }

}
