//
//  Collection.swift
//  NEditor
//
//  Created by 417.72KI on 2020/07/24.
//  Copyright © 2020 417.72KI. All rights reserved.
//

import Foundation

extension Collection {
    func filterIf(_ condition: @autoclosure () -> Bool, _ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        try lazy.filterIf(condition(), isIncluded)
    }
}

extension LazySequence {
    func filterIf(_ condition: @autoclosure () -> Bool, _ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        guard condition() else { return [Element](self) }
        return try filter(isIncluded)
    }
}
