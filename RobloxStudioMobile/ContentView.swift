//
//  ContentView.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI

var loading = false
struct ContentView: View {
    @State var loadingHere = true
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
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
            }.saturation(loadingHere ? 0 : 1)
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
            }.opacity(loadingHere ? 1 : 0)
            .onReceive(timer, perform: { _ in
                print(loading)
                if loading{
                    loadingHere = true
                }else{
                    loadingHere = false
                }
            })
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
    @State var file = ""
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
                        file = input
                        fileName = (selectedFile.description as NSString).lastPathComponent.removingPercentEncoding!
                        loading = true
                        print("now loading")
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
