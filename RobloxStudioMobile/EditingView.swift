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
    @State var leftOffset: Bool = false
    @State var rightOffset: Bool = false
    
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
                        .padding(.trailing, -7)
                        .frame(width: geometry.size.width*0.25)
                        .animation(.default)
                        .offset(x: leftOffset ? geometry.size.width * -0.25 - 7 : 0)
                    Divider()
                        .animation(.default)
                        .offset(x: leftOffset ? geometry.size.width * -0.25 - 7 : 0)
                    mainView(additional: (leftOffset ? geometry.size.width * 0.25 + 7 : 0) + (rightOffset ? geometry.size.width * 0.25 + 9: 0))
                        .offset(x: (leftOffset ? geometry.size.width * -0.25 - 7 : 0))
                        .animation(.default)
                    Divider()
                        .animation(.default)
                        .offset(x: (rightOffset ? geometry.size.width * 0.25 + 7 : 0))
                    PropertyView()
                        .padding(.leading, -7)
                        .frame(width: geometry.size.width*0.25)
                        .animation(.default)
                        .offset(x: (rightOffset ? geometry.size.width * 0.25 + 7 : 0))
                }
            }.navigationBarTitle(fileName, displayMode: .inline)
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarLeading){
                    Button(action:{presentationMode.wrappedValue.dismiss()}, label:{
                        Text("Done")
                    }).buttonStyle(PlainButtonStyle())
                    Button(action: {
                        leftOffset.toggle()
                    }, label: {
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
                    Button(action: {
                        rightOffset.toggle()
                    }, label: {
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

struct mainView: View{
    let additional: CGFloat
    
    init(additional: CGFloat){
        self.additional = additional
    }
    
    var body: some View{
        GeometryReader{ thisGeometry in
            scriptView()
                .frame(width: thisGeometry.size.width + 7 + additional)
        }
    }
}

struct scriptView: View{
    @EnvironmentObject var script: ScriptFile
    @State var scriptEditable = ""
    
    var body: some View{
        TextEditor(text: $scriptEditable)
            .onAppear(){
                scriptEditable = script.file
            }
            .onChange(of: script.file){_ in
                scriptEditable = script.file
            }
            .environmentObject(script)
    }
}

struct enviromentView: View{
    var body: some View{
        Text("Enviroment Placeholder")
    }
}

struct EditingView_Previews: PreviewProvider {
    static var previews: some View {
//        EditingView(file: "", fileName: "")
        mainView(additional: 0)
    }
}
