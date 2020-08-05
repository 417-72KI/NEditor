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
                        .onDrop(of: [kUTTypeFileURL as String],
                                isTargeted: $dragOver) { providers in
                                    guard providers.count == 1 else { return false }
                                    providers[0].loadItem(forTypeIdentifier: kUTTypeFileURL as String,
                                                          options: nil) { data, _ in
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
                }
                .disabled(!viewModel.renameButtonEnabled)
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
    var beforeAndAfterRenamingFiles: [(URL, URL)] {
        guard let directory = directory else { return [] }
        let originalFiles = originalFilesText
            .split(separator: "\n")
            .map(String.init)
            .map(directory.appendingPathComponent)
        let renamingFiles = renamingFilesText
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .map(directory.appendingPathComponent)
        precondition(originalFiles.allSatisfy { fileManager.fileExists(atPath: $0.path) })

        guard originalFiles.count == renamingFiles.count else { return [] }
        return Array(zip(originalFiles, renamingFiles))
    }
}

extension ContentView.ViewModel {
    func loadUrl(_ url: URL) {
        do {
            files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
            directory = url
        } catch {
            print(error)
        }
    }

    func reload() {
        guard let directory = directory else { return }
        loadUrl(directory)
    }

    func rename() {
        beforeAndAfterRenamingFiles.forEach {
            if $0 == $1 {
                print("\"\($0.path)\" not renamed.")
                return
            }
            print("rename \"\($0.path)\" to \"\($1.path)\"")
            do {
                try fileManager.moveItem(at: $0, to: $1)
            } catch {
                print(error)
            }
        }
        reload()
    }
}

private extension ContentView.ViewModel {
    func updateState() {
        let filteredFiles = files.filterIf(!filter.isEmpty) { $0.lastPathComponent.matches(withWildcard: filter, partial: true) }
                .filterIf(isDirectoryOnly) { [fileManager] in fileManager.isDirectory(atPath: $0.path) }

        DispatchQueue.main.async {
            self.originalFilesText = filteredFiles.lazy
                .map(\.lastPathComponent)
                .joined(separator: "\n")
            self.renamingFilesText = self.originalFilesText
            self.renameButtonEnabled = !filteredFiles.isEmpty
        }
    }
}

// MARK: - preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
