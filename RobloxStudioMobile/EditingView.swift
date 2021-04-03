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
    @StateObject var propertyList = PropertyInfoArray()
    let file: String
    let fileName: String
    let parsedArray: Array<RbxObject>
    @State var dummy = ""
    
    init(file: String, fileName: String){
        self.file = file
        self.fileName = fileName
        
        self.parsedArray = parseFile(data: file)
        
        print("done")
    }
    
    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                HStack{
                    mainListView(parsedArray: parsedArray, file: file)
                        .frame(width: geometry.size.width*0.25)
                    Divider()
                    VStack{
                        Text("Enviromental Placeholder")
                    }.frame(minWidth: 0, maxWidth: .infinity)
                    Divider()
                    VStack{
                        PropertyView()
                    }
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
        .onAppear{
            loading.loading = false
        }
    }
}

struct PropertyView: View{
    @EnvironmentObject var properties: PropertyInfoArray
    
    var body: some View{
        List(0..<properties.properties.count, id: \.self){property in
            PropertyCell(arraySlot: property)
        }
        .onChange(of: properties.properties.count, perform: { value in
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Code@*/ /*@END_MENU_TOKEN@*/
        })
        .environmentObject(properties)
    }
}

struct PropertyCell: View{
    @State var newPropertyValue: String = ""
    @EnvironmentObject var properties: PropertyInfoArray
    let arraySlot: Int
    
    init(arraySlot: Int){
        self.arraySlot = arraySlot
    }
    
    var body: some View{
        HStack{
            Text(properties.properties[arraySlot].name)
            TextField("", text: $newPropertyValue)
                .onChange(of: newPropertyValue, perform: { value in
                    properties.properties[arraySlot].value = newPropertyValue
                })
        }
        .environmentObject(properties)
        .onAppear(){
            self.newPropertyValue = properties.properties[arraySlot].value as! String
        }
    }
}

struct EditingView_Previews: PreviewProvider {
    static var previews: some View {
        EditingView(file: "", fileName: "")
    }
}
