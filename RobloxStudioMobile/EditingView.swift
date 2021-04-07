//
//  EditingView.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI

struct EditingView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var loading: LoadingFile
    @StateObject var script = ScriptFile()
    @StateObject var propertyList = PropertyInfoArray()
    let file: String
    let fileName: String
    let parsedArray: Array<RbxObject>
    @State var dummy = ""
    
    init(file: String, fileName: String){
        self.file = file
        self.fileName = fileName
        
        self.parsedArray = parseFile(data: file)
        
    }
    
    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                HStack{
                    mainListView(parsedArray: parsedArray, file: file)
                        .frame(width: geometry.size.width*0.25)
                    Divider()
                    MainView()
                        .frame(minWidth: 0, maxWidth: .infinity)
                    Divider()
                    PropertyView()
                        .frame(width: geometry.size.width*0.25)
                }
            }.navigationBarTitle(fileName, displayMode: .inline)
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarLeading){
                    Button(action:{presentationMode.wrappedValue.dismiss()}, label:{
                        Text("Done")
                    }).buttonStyle(PlainButtonStyle())
                    Button(action: {}, label: {
                        Image(systemName: "sidebar.left")
                    })
                    Button(action: {}, label: {
                        Image(systemName: "arrow.uturn.backward.circle")
                    })
                    Button(action: {}, label: {
                        Image(systemName: "arrow.uturn.forward.circle")
                    })
                }
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Button(action: {}, label: {
                        Image(systemName: "square.and.arrow.up")
                    })
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "info.circle")
                    })
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "sidebar.right")
                    })
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(loading)
        .environmentObject(propertyList)
        .environmentObject(script)
        .onAppear{
            loading.loading = false
        }
    }
}

struct MainView: View{
    @EnvironmentObject var script: ScriptFile
    @State var scriptEditable = ""
    
    var body: some View{
        TextEditor(text: $scriptEditable)
            .onAppear(){
                scriptEditable = script.file
            }
            .environmentObject(script)
    }
}

struct EditingView_Previews: PreviewProvider {
    static var previews: some View {
        EditingView(file: "", fileName: "")
    }
}
