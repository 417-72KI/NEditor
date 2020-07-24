//
//  ContentView.swift
//  NEditor
//
//  Created by 417.72KI on 2020/05/16.
//  Copyright © 2020 417.72KI. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = ViewModel(fileManager: .default)
    @State private var dragOver = false
    @State private var isDialogShowing = false

    var body: some View {
            VStack {
                VStack {
                    HStack {
                        Text("Folder: ")
                        TextField("", text: $viewModel.directoryText)
                            .disabled(true)
                    }
                    HStack {
                        Text("Filter: ")
                        TextField("*.mp3 *.jpg etc...", text: $viewModel.filter)
                        Toggle("Directory only", isOn: $viewModel.isDirectoryOnly)
                    }
                }.padding(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                HStack {
                    MacEditorTextView(text: $viewModel.originalFilesText,
                                      isEditable: false)
                        .onDrop(
                            of: [kUTTypeFileURL as String],
                            isTargeted: $dragOver
                        ) { providers in
                            guard providers.count == 1 else { return false }
                            providers[0].loadItem(
                                forTypeIdentifier: kUTTypeFileURL as String,
                                options: nil
                            ) { data, error in
                                guard let url = (data as? Data)
                                    .flatMap({ String(data: $0, encoding: .utf8) })
                                    .flatMap(URL.init) else { return }
                                self.viewModel.loadUrl(url)
                            }
                            return true
                    }
                    MacEditorTextView(text: $viewModel.renamingFilesText)
                }
                Toggle("Confirm before rename", isOn: $viewModel.confirmBeforeRename)
                Button("Rename") {
                    if self.viewModel.confirmBeforeRename {
                        self.isDialogShowing = true
                    } else {
                        self.viewModel.rename()
                    }
                }
                .alert(isPresented: $isDialogShowing) {
                    Alert(title: Text("Confirm"),
                          message: Text("Are you sure?"),
                          primaryButton: .default(Text("Do")) { self.viewModel.rename() },
                          secondaryButton: .cancel(Text("Cancel"))
                    )
                }.disabled(!viewModel.renameButtonEnabled)
            }.padding(.bottom, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension ContentView {
    final class ViewModel: ObservableObject {
        private var directory: URL? {
            didSet {
                DispatchQueue.main.async {
                    self.directoryText = self.directory?.path ?? ""
                }
            }
        }
        private var files: [URL] = [] {
            didSet { updateState() }
        }

        @Published var directoryText: String = ""
        @Published var filter: String = "" {
            didSet { updateState() }
        }
        @Published var isDirectoryOnly: Bool = false {
            didSet { updateState() }
        }
        @Published var originalFilesText: String = ""
        @Published var renamingFilesText: String = ""

        @Published var renameButtonEnabled: Bool = false
        @Published var confirmBeforeRename: Bool = false

        let fileManager: FileManager

        init(fileManager: FileManager) {
            self.fileManager = fileManager
        }
    }
}

extension ContentView.ViewModel {
    var filteredFiles: [URL] {
        files.filterIf(!filter.isEmpty) { $0.lastPathComponent.matches(withWildcard: filter, partial: true) }
            .filterIf(isDirectoryOnly) { [fileManager] in fileManager.isDirectory(atPath: $0.path) }
    }
}

extension ContentView.ViewModel {
    func loadUrl(_ url: URL) {
        do {
            files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            directory = url
        } catch {
            print(error)
        }
    }

    func rename() {
        print("before: \(originalFilesText)")
        print("after: \(renamingFilesText)")
    }
}

private extension ContentView.ViewModel {
    func updateState() {
        DispatchQueue.main.async {
            self.originalFilesText = self.filteredFiles.lazy
                .map(\.lastPathComponent)
                .joined(separator: "\n")
            self.renamingFilesText = self.originalFilesText
            self.renameButtonEnabled = !self.filteredFiles.isEmpty
        }
    }
}

// MARK: - preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
