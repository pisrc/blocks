//
//  CGSize+Extension.swift
//  Blocks
//
//  Created by ryan on 25/12/2016.
//  Copyright © 2016 pi. All rights reserved.
//

import Foundation

extension CGSize: Comparable {
    public static func <(lhs: CGSize, rhs: CGSize) -> Bool {
        let ld = lhs.width * lhs.height
        let rd = rhs.width * rhs.height
        return ld < rd
    }
}
