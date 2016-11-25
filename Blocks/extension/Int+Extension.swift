//
//  Int+Extension.swift
//  Blocks
//
//  Created by ryan on 25/11/2016.
//  Copyright © 2016 pi. All rights reserved.
//

import Foundation

extension Int {
    
    // + 하다가 max를 넘으면 0
    public func rotate(max: Int) -> Int {
        return (self + 1 <= max) ? self + 1 : 0
    }
    
    // - 하다가 0보다 작으면 max
    public func rotateBack(max: Int) -> Int {
        return (0 <= self - 1) ? self - 1 : max
    }
}
