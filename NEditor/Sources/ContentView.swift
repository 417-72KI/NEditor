//
//  ContentView.swift
//  NEditor
//
//  Created by 417.72KI on 2020/05/16.
//  Copyright © 2020 417.72KI. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = ViewModel()
    @State private var dragOver = false

    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    MacEditorTextView(text: self.$viewModel.originalFilesText,
                                      isEditable: false)
                        .frame(height: geometry.size.height)
                        .onDrop(of: [kUTTypeFileURL as String],
                                isTargeted: self.$dragOver) { providers in
                                    guard providers.count == 1 else { return false }
                                    providers[0].loadItem(forTypeIdentifier: kUTTypeFileURL as String, options: nil) { (data, error) in
                                        guard let url = (data as? Data).flatMap({ String(data: $0, encoding: .utf8) })
                                            .flatMap(URL.init) else { return }
                                        self.viewModel.loadUrl(url)
                                    }
                                    return true
                    }
                    MacEditorTextView(text: self.$viewModel.renamingFilesText)
                        .frame(height: geometry.size.height)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension ContentView {
    final class ViewModel: ObservableObject {
        private var directory: URL?

        @Published var originalFilesText: String = ""
        @Published var renamingFilesText: String = ""
    }
}

extension ContentView.ViewModel {
    func loadUrl(_ url: URL) {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
                .map { $0.lastPathComponent }
            DispatchQueue.main.async {
                self.originalFilesText = files.joined(separator: "\n")
                self.renamingFilesText = self.originalFilesText
                self.directory = url
            }
        } catch {
            print(error)
        }
    }
}


// MARK: - preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
