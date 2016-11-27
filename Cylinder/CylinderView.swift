//
//  CylinderView.swift
//  Blocks
//
//  Created by pi on 23/11/2016.
//  Copyright © 2016 pi. All rights reserved.
//

import UIKit
import Blocks

public protocol CylinderViewDelegate: class {
    func cylinderViewNumberOfPages(_ cylinderView: CylinderView) -> Int
    func cylinderView(_ cylinderView: CylinderView, viewAt index: Int) -> UIView
    func cylinderView(_ cylinderView: CylinderView, didChange view: UIView)
    func cylinderViewStartIndex(_ cylinderView: CylinderView) -> Int
}

public class CylinderPage: UIView {
    var index = 0
    public func set(view: UIView, index: Int) {
        self.index = index
        self.set(child: view)
    }
}

public class CylinderView: UIView, UIScrollViewDelegate {
    
    private var scrollView: UIScrollView!
    
    private var child1 = CylinderPage()
    private var child2 = CylinderPage()
    private var child3 = CylinderPage()
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
            
            guard let delegate = delegate else {
                return
            }
            
            let count = delegate.cylinderViewNumberOfPages(self)
            let startIndex = delegate.cylinderViewStartIndex(self)
            leftChild.index = startIndex
            centerChild.index = leftChild.index.rotate(max: count - 1)
            rightChild.index = centerChild.index.rotate(max: count - 1)
            
            reloadData()
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
        
        scrollView.addSubview(leftChild)
        scrollView.addSubview(centerChild)
        scrollView.addSubview(rightChild)
        
        addSubview(scrollView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        scrollView.frame = rect
        scrollView.contentSize = CGSize(width: rect.width * 3, height: rect.height)
        
        pageWidth = rect.width
        
        leftChild.frame = CGRect(x: 0, y: 0, width: pageWidth, height: rect.height)
        centerChild.frame = CGRect(x: pageWidth, y: 0, width: pageWidth, height: rect.height)
        rightChild.frame = CGRect(x: pageWidth * 2, y: 0, width: pageWidth, height: rect.height)
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        draw(frame)
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
        switch currentPage {
        case 1:
            if let view = leftChild.subviews.first {
                delegate?.cylinderView(self, didChange: view)
            }
        case 2:
            if let view = centerChild.subviews.first {
                delegate?.cylinderView(self, didChange: view)
            }
        case 3:
            if let view = rightChild.subviews.first {
                delegate?.cylinderView(self, didChange: view)
            }
        default:
            break
        }
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
            
            leftChild.set(view: delegate.cylinderView(self, viewAt: leftIndex), index: leftIndex)
            rightChild.set(view: delegate.cylinderView(self, viewAt: rightIndex), index: rightIndex)
        }
        
        scrollView.contentOffset = CGPoint(x: frame.width, y: 0)
    }
    
    public func reloadData() {
        guard let delegate = delegate else {
            return
        }
        // 시작 index 확인
        leftChild.index = delegate.cylinderViewStartIndex(self)
        
        leftChild.set(view: delegate.cylinderView(self, viewAt: leftChild.index), index: leftChild.index)
        centerChild.set(view: delegate.cylinderView(self, viewAt: centerChild.index), index: centerChild.index)
        rightChild.set(view: delegate.cylinderView(self, viewAt: rightChild.index), index: rightChild.index)
        
        if let view = leftChild.subviews.first {
            delegate.cylinderView(self, didChange: view)
        }
    }
}
