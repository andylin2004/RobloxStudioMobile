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
    
    var body: some View{
        List{
            PropertyRenderer()
        }
    }
}

struct PropertyRenderer: View{
    @EnvironmentObject var properties: PropertyInfoArray
    
    var body: some View{
        ForEach(properties.properties){property in
            if property.type == "Array"{
                PropertyCellArray(property: property)
            }else{
                PropertyCell(property: property)
            }
        }
        .environmentObject(properties)
    }
}

struct PropertyCell: View{
    @State var newPropertyValue: String = ""
    @EnvironmentObject var properties: PropertyInfoArray
    let property: PropertyInfo
    
    init(property: PropertyInfo){
        self.property = property
        
        newPropertyValue = property.value as! String
    }
    
    var body: some View{
        HStack{
            Text(property.name)
            TextField("", text: $newPropertyValue)
                .onChange(of: newPropertyValue, perform: { value in
                    if property.id < properties.properties.count{
                        properties.properties[property.id].value = newPropertyValue
                    }
                })
        }
        .environmentObject(properties)
        .onAppear(){
            newPropertyValue = property.value as! String
        }
        .onChange(of: property.name, perform: { value in
            newPropertyValue = property.value as! String
        })
    }
}

struct PropertyCellArray: View{
    @State var newPropertyValue: Dictionary = [:]
    @EnvironmentObject var properties: PropertyInfoArray
    let property: PropertyInfo
    
    init(property: PropertyInfo){
        self.property = property
        
        newPropertyValue = property.value as! Dictionary<String, Double>
    }
    var body: some View{
        DisclosureGroup{
            ForEach(Array((property.value as! Dictionary<String, Double>).keys), id: \.self){item in
                Text(((property.value as! Dictionary<String, Double>)[item])!.description)
            }
        } label: {
            Text(property.name)
        }
        .environmentObject(properties)
        .onAppear(){
            newPropertyValue = property.value as! Dictionary
        }
        .onChange(of: property.name, perform: { value in
            newPropertyValue = property.value as! Dictionary
        })
    }
}

struct EditingView_Previews: PreviewProvider {
    static var previews: some View {
        EditingView(file: "", fileName: "")
    }
}
