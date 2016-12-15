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
    
    // ring 형 순열 버퍼에서 에서 step 만큼 증가시켰을때 index 값을 반환
    // ex: 4.rotate(next: -1, length: 3) -> 0
    // length:3 에의한 [0,1,2] 순열중 4번째 index는 1, 0에서 -1 step 은 0
    public func rotate(next step: Int, length: Int) -> Int {
        
        guard self < length else {
            return 0.rotate(next: self + step, length: length)
        }
        
        let nextIdx = (self + step) % length
        if 0 <= nextIdx {
            return nextIdx
        }
        return length + nextIdx
    }
}
