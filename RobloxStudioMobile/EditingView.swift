//
//  EditingView.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI

struct EditingView: View {
    @Environment(\.presentationMode) var presentationMode
    let file: String
    let fileName: String
    let parsedArray: Array<RbxObject>
    
    init(file: String, fileName: String){
        self.file = file
        self.fileName = fileName
        
        self.parsedArray = parseFile(data: file)
        
        loading = false
        print("done")
    }
    
    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                HStack{
                    VStack{
                        ListView()
                        List(parsedArray, id: \.name){ item in
                            VStack{
                                Text(item.name)
                                Text(item.propertyEnd.description)
                                Text(item.childEnd?.description ?? "No child")
                            }
                        }
                    }.frame(width: geometry.size.width*0.25)
                    Divider()
                    VStack{
                        Text("Enviromental Placeholder")
                    }.frame(minWidth: 0, maxWidth: .infinity)
                    Divider()
                    VStack{
                        Text("Properties Placeholder")
                    }.frame(width: geometry.size.width*0.25)
                    
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
    }
}

struct EditingView_Previews: PreviewProvider {
    static var previews: some View {
        EditingView(file: "", fileName: "")
    }
}
