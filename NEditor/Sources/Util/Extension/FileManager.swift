//
//  FileManager.swift
//  NEditor
//
//  Created by 417.72KI on 2020/07/24.
//  Copyright © 2020 417.72KI. All rights reserved.
//

import Foundation

extension FileManager {
    func isDirectory(atPath path: String) -> Bool {
        var isDirectory: ObjCBool = false
        guard fileExists(atPath: path, isDirectory: &isDirectory) else { return false }
        return isDirectory.boolValue
    }
}
