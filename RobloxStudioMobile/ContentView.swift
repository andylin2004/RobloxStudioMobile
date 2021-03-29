//
//  ContentView.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    var body: some View {
        NavigationView{
            List{
                NavigationLink(destination: ExploreView()){
                    Label("Explore", systemImage: "house")
                }
                NavigationLink(destination: FileView()){
                    Label("Files", systemImage: "folder")
                }
                NavigationLink(
                    destination: SettingView(),
                    label: {
                        Label("Settings", systemImage: "gear")
                    })
                Section(header: Text("Dev Only")){
                    NavigationLink(
                        destination: EditingView(file: "")
                            .navigationBarHidden(true),
                        label: {
                            Text("Dev")
                        })
                }
                Section(header: Text("Favorites")){
                    
                }
            }.listStyle(SidebarListStyle())
            .navigationTitle("Home")
            .toolbar{
                EditButton()
            }
            ExploreView()
        }
    }
}

struct ExploreView: View{
    var body: some View{
        Text("Explore placeholder")
            .navigationTitle("Explore")
    }
}

struct FileView: View{
    @State var isImporting = false
    @State var file: InputDoument = InputDoument(input: "")
    @State var isPresented = false
    
    var body: some View{
        Text("Files placeholder")
            .navigationTitle("Files")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu{
                        Button(
                            action: {isPresented.toggle()},
                            label: {
                                Label("Add New", systemImage: "doc.badge.plus")
                            }
                        )
                        Button(
                            action: {isImporting = true},
                            label: {Label("Import from Files", systemImage: "square.and.arrow.down")
                            }
                        )
                    }
                    label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $isPresented, content: {EditingView(file: "")})
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.rbxlx],
                allowsMultipleSelection: false
            ) { result in
                do {
                    guard let selectedFile: URL = try result.get().first else { return }
                    if selectedFile.startAccessingSecurityScopedResource() {
                        guard let input = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                        defer { selectedFile.stopAccessingSecurityScopedResource() }
                        file.input = input
                        isPresented.toggle()
                    } else {
                        // Handle denied access
                    }
                } catch {
                    // Handle failure.
                    print("Unable to read file contents")
                    print(error.localizedDescription)
                }
            }
    }
}

struct InputDoument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.plainText] }
    
    var input: String
    
    init(input: String) {
        self.input = input
    }
    
    init(configuration: FileDocumentReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        input = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: input.data(using: .utf8)!)
    }
    
}

struct SettingView: View{
    var body: some View{
        Text("Settings placeholder")
            .navigationTitle("Settings")
    }
}

extension UTType {
    // Word documents are not an existing property on UTType
    static var rbxlx: UTType {
        // Look up the type from the file extension
        UTType.types(tag: "rbxlx", tagClass: .filenameExtension, conformingTo: .xml).first!
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
