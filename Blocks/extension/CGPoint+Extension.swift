//
//  CGPoint+Extension.swift
//  Blocks
//
//  Created by ryan on 25/12/2016.
//  Copyright © 2016 pi. All rights reserved.
//

import Foundation

extension CGPoint {
    public func distance(to p:CGPoint) -> CGFloat {
        return sqrt(pow((p.x - x), 2) + pow((p.y - y), 2))
    }
}
