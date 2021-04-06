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
    @EnvironmentObject var properties: PropertyInfoArray
    
    var body: some View{
        List{
            ForEach(properties.properties, id: \.self){property in
                PropertyCell(property: property)
            }
        }
        .environmentObject(properties)
    }
}

struct PropertyCell: View{
    @State var newPropertyValue: Array<OrderedDict> = []
    @EnvironmentObject var properties: PropertyInfoArray
    let property: PropertyInfo
    
    init(property: PropertyInfo){
        self.property = property
    }
    
    var body: some View{
        if property.type == "Array"{
            DisclosureGroup{
                ForEach(0..<newPropertyValue.count, id: \.self){indice in
                    HStack{
                        Text(property.value[indice].key)
                        TextField("", text: $newPropertyValue[indice].value)
                            .onChange(of: newPropertyValue[indice].value){_ in
                                properties.properties[property.id].value[indice].value = newPropertyValue[indice].value
                            }
                    }
                }
            } label: {
                Text(property.name)
            }
            .environmentObject(properties)
            .onAppear(){
                self.newPropertyValue = property.value
            }
            .onChange(of: property.value){_ in
                self.newPropertyValue = property.value
            }
        }else if property.value.count > 0{
            HStack{
                Text(property.name)
                ForEach(0..<newPropertyValue.count, id: \.self){indice in
                    TextField("", text: $newPropertyValue[indice].value)
                        .onChange(of: newPropertyValue[indice].value){_ in
                            if properties.properties.count > property.id{
                                properties.properties[property.id].value[indice].value = newPropertyValue[indice].value
                            }
                        }
                }
            }
            .environmentObject(properties)
            .onAppear(){
                self.newPropertyValue = property.value
            }
            .onChange(of: property.value){_ in
                self.newPropertyValue = property.value
            }
        }
    }
}

struct EditingView_Previews: PreviewProvider {
    static var previews: some View {
        EditingView(file: "", fileName: "")
    }
}
