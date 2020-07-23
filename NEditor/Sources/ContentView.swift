//
//  ContentView.swift
//  NEditor
//
//  Created by 417.72KI on 2020/05/16.
//  Copyright © 2020 417.72KI. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var originalFileNames: String = ""
    @State private var files: String = ""
    @State private var dragOver = false

    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    MacEditorTextView(text: self.$originalFileNames)
                        .editable(false)
                        .frame(height: geometry.size.height)
                    MacEditorTextView(text: self.$files)
                        .frame(height: geometry.size.height)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
