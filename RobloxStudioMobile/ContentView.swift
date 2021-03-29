//
//  ContentView.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI

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
                        destination: EditingView(file: InputDocument(input: ""), fileName: "")
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
    @State var file: InputDocument = InputDocument(input: "")
    @State var fileName = ""
    @State var editorShown = false
    @State var alertShown = false
    
    var body: some View{
        Text("Files placeholder")
            .navigationTitle("Files")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu{
                        Button(
                            action: {editorShown.toggle()},
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
            .fullScreenCover(isPresented: $editorShown, content: {EditingView(file: file, fileName: fileName)})
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
                        fileName = (selectedFile.description as NSString).lastPathComponent.removingPercentEncoding!
                        editorShown.toggle()
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

struct SettingView: View{
    var body: some View{
        Text("Settings placeholder")
            .navigationTitle("Settings")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
