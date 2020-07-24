//
//  String.swift
//  NEditor
//
//  Created by 417.72KI on 2020/07/24.
//  Copyright © 2020 417.72KI. All rights reserved.
//

import Foundation

extension String {
    func matches(withWildcard pattern: String, partial: Bool = false) -> Bool {
        let pattern = partial ? "*\(pattern)*" : pattern
        let pred = NSPredicate(format: "self like[c] %@", pattern)
        let result = NSArray(object: self).filtered(using: pred)
        return !result.isEmpty
    }
}
