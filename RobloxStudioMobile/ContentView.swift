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
                        destination: EditingView()
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
    @State var showDocumentViewer = false
    @State var fileContent = ""
    var body: some View{
        Text("Files placeholder")
            .navigationTitle("Files")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu{
                        Button(
                            action: {EditingView()},
                            label: {
                                Label("Add New", systemImage: "doc.badge.plus")
                            }
                        )
                        Button(
                            action: {showDocumentViewer = true},
                            label: {Label("Import from Files", systemImage: "square.and.arrow.down")
                            }
                        )
                    }
                    label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: self.$showDocumentViewer, content: {
                DocumentPicker(fileContent: $fileContent)
            })
    }
}


struct SettingView: View{
    var body: some View{
        Text("Settings placeholder")
            .navigationTitle("Settings")
    }
}

struct DocumentPicker: UIViewControllerRepresentable{
    @Binding var fileContent: String
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(fileContent: $fileContent)
    }
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let controller: UIDocumentPickerViewController
        
        controller = UIDocumentPickerViewController(forOpeningContentTypes: [.data], asCopy: true)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {}
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate{
    
    @Binding var fileContent: String
    
    init(fileContent: Binding<String>){
        _fileContent = fileContent
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        let fileURL = urls[0]
        do{
            fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            print(fileContent)
        }catch let error{
            print(error.localizedDescription)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
