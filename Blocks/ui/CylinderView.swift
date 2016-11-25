//
//  CylinderView.swift
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

public class CylinderPage: UIView {
    var index = 0
    
    public func set(view: UIView, index: Int) {
        self.index = index
        
        set(child: view)
        let consts = BConstraintsBuilder(view: view, name: "view")
            .add(vfs: "H:|[view]|", "V:|[view]|")
            .constraints
        removeConstraints(constraints)
        addConstraints(consts)
    }
}

public class CylinderView: UIView, UIScrollViewDelegate {
 
    
    private var scrollView: UIScrollView!
    
    public var child1 = CylinderPage()
    public var child2 = CylinderPage()
    public var child3 = CylinderPage()
    private var leftChild: CylinderPage! {
        didSet {
            leftChild.frame.origin = CGPoint(x: 0, y: 0)
        }
    }
    private var centerChild: CylinderPage! {
        didSet {
            centerChild.frame.origin = CGPoint(x: pageWidth, y: 0)
        }
    }
    private var rightChild: CylinderPage! {
        didSet {
            rightChild.frame.origin = CGPoint(x: pageWidth * 2, y: 0)
        }
    }
    private var pageWidth: CGFloat = 0.0
    private var index = 0
    private var currentPage: Int {
        return Int((scrollView.contentOffset.x + (0.5 * scrollView.frame.size.width)) / scrollView.frame.size.width) + 1
    }
    
    public weak var delegate: CylinderViewDelegate? {
        didSet {
            if let view = delegate?.cylinderView?(self, viewAt: leftChild.index) {
                leftChild.set(view: view, index: leftChild.index)
            }
            if let view = delegate?.cylinderView?(self, viewAt: centerChild.index) {
                centerChild.set(view: view, index: centerChild.index)
            }
            if let view = delegate?.cylinderView?(self, viewAt: rightChild.index) {
                rightChild.set(view: view, index: rightChild.index)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        leftChild = child1
        centerChild = child2
        rightChild = child3
        
        leftChild.index = 0
        centerChild.index = 1
        rightChild.index = 2
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.isDirectionalLockEnabled = true
        
        scrollView.addSubview(child1)
        scrollView.addSubview(child2)
        scrollView.addSubview(child3)
        
        addSubview(scrollView)
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        scrollView.frame = rect
        scrollView.contentSize = CGSize(width: rect.width * 3, height: rect.height)
        
        pageWidth = rect.size.width
        
        leftChild.frame = CGRect(x: 0, y: 0, width: pageWidth, height: rect.size.height)
        centerChild.frame = CGRect(x: pageWidth, y: 0, width: pageWidth, height: rect.size.height)
        rightChild.frame = CGRect(x: pageWidth * 2, y: 0, width: pageWidth, height: rect.size.height)
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        switch currentPage {
        case 1:
            centering(child: 1)
        case 2:
            break
        case 3:
            centering(child: 3)
        default:
            break
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.cylinderView?(self, didChangeViewIndex: currentPage - 1)
    }
    
    private func centering(child: Int) {
        
        switch child {
        case 1:
            let tmp = rightChild
            rightChild = centerChild
            centerChild = leftChild
            leftChild = tmp
            break
        case 3:
            let tmp = leftChild
            leftChild = centerChild
            centerChild = rightChild
            rightChild = tmp
            break
        default:
            break
        }
        
        // center 를 제외한, left와 right는 view 갱신 되어야 함
        if let delegate = delegate {
            let count = delegate.cylinderViewNumberOfPages(self)
            let leftIndex = centerChild.index.rotateBack(max: count - 1)
            let rightIndex = centerChild.index.rotate(max: count - 1)
            if let view = delegate.cylinderView?(self, viewAt: leftIndex) {
                leftChild.set(view: view, index: leftIndex)
            }
            if let view = delegate.cylinderView?(self, viewAt: rightIndex) {
                rightChild.set(view: view, index: rightIndex)
            }
        }
        
        scrollView.contentOffset = CGPoint(x: frame.width, y: 0)
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