//
//  MacEditorTextView+Extension.swift
//  NEditor
//
//  Created by 417.72KI on 2020/07/24.
//  Copyright © 2020 417.72KI. All rights reserved.
//

import SwiftUI

extension MacEditorTextView {
    func editable(_ flag: Bool) -> some View {
        var view = self
        view.isEditable = flag
        return view
    }
}
