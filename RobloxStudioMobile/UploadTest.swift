//
//  UploadTest.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI

var layerClass: AnyClass { return CATiledLayer.self }

struct UploadTest: View {
    @State private var fileContent = ""
    @State private var showDocumentViewer = false

    var body: some View {
        VStack{
            ScrollView{
                TextEditor(text: $fileContent)
            }.padding()
            
            Button("Import File"){
                showDocumentViewer = true
            }
        }.sheet(isPresented: self.$showDocumentViewer, content: {
            DocumentPicker(fileContent: $fileContent)
        })
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

struct UploadTest_Previews: PreviewProvider {
    static var previews: some View {
        UploadTest()
    }
}
