//
//  CGRect+Extension.swift
//  Blocks
//
//  Created by ryan on 25/12/2016.
//  Copyright © 2016 pi. All rights reserved.
//

import Foundation

extension CGRect: Comparable {
    public static func <(lhs: CGRect, rhs: CGRect) -> Bool {
        return lhs.width < rhs.width && lhs.height < rhs.height
    }
}
