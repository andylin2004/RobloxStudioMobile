//
//  ContentView.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var loading = LoadingFile()
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        ZStack{
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
                            destination: EditingView(file: "", fileName: "")
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
            .saturation(loading.loading ? 0.2 : 1)
            ZStack{
                Rectangle()
                    .opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(x: 3, y: 3, anchor: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .frame(width: 100, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .background(Color.black)
                    .opacity(0.5)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
            }.opacity(loading.loading ? 1 : 0)
        }
        .environmentObject(self.loading)
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
    @State var file = ""
    @State var fileName = ""
    @State var editorShown = false
    @State var alertShown = false
    @EnvironmentObject var loading: LoadingFile
    
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
            .environmentObject(self.loading)
            .fullScreenCover(isPresented: $editorShown, content: {EditingView(file: file, fileName: fileName)})
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.rbxlx],
                allowsMultipleSelection: false
            ) { result in
                do {
                    loading.loading = true
                    guard let selectedFile: URL = try result.get().first else {
                        loading.loading = false
                        return }
                    if selectedFile.startAccessingSecurityScopedResource() {
                        guard let input = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                        defer { selectedFile.stopAccessingSecurityScopedResource() }
                        file = input
                        fileName = (selectedFile.description as NSString).lastPathComponent.removingPercentEncoding!
                        print("now loading")
                        editorShown.toggle()
                    } else {
                        // Handle denied access
                        loading.loading = false
                    }
                } catch {
                    // Handle failure.
                    print("Unable to read file contents")
                    print(error.localizedDescription)
                    loading.loading = false
                }
            }
            .environmentObject(loading)
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
