//
//  SideViews.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI

struct childView: View{
    let children: Array<RbxObject>
    let data: String
    
    init(startChild: Int, endChild: Int, data: String){
        self.children = parseFile(data: data.split(whereSeparator: \.isNewline), startAtLine: startChild, endAtLine: endChild)
        self.data = data
    }
    
    var body: some View{
        ForEach(children, id: \.name){ child in
            if child.childEnd == nil && child.childStart == nil{
                ListButton(data: data, child: child)
            }else{
                DisclosureGroup{
                    childView(startChild: child.childStart!, endChild: child.childEnd!, data: data)
                } label: {
                    ListButton(data: data, child: child)
                }
            }
        }
    }
}

struct mainListView: View{
    let file: String
    
    init(parsedArray: Array<RbxObject>, file: String){
        self.file = file
    }
    
    var body: some View{
        List{
            childView(startChild: 3, endChild: file.split(whereSeparator: \.isNewline).count-5, data: file)
        }
    }
}

struct ListButton: View{
    let data: String
    let child: RbxObject
    @EnvironmentObject var propertyInfo: PropertyInfoArray
    
    init(data: String, child: RbxObject) {
        self.data = data
        self.child = child
    }
    
    var body: some View {
        Button(action:{
            propertyInfo.properties = collectProperty(data: data.split(whereSeparator: \.isNewline), startAtLine: child.propertyStart+1, endAtLine: child.propertyEnd)
            propertyInfo.id = child.id
            propertyInfo.name = child.name
        }){
            Text(child.name)
                .foregroundColor(Color(UIColor.label))
        }
        .environmentObject(propertyInfo)
    }
}

struct PropertyView: View{
    @EnvironmentObject var properties: PropertyInfoArray
    @EnvironmentObject var script: ScriptFile
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View{
        if properties.properties.count == 0{
            VStack{
                Spacer()
                Text("No Element Selected")
                    .font(.title)
                Spacer()
            }
        }else{
            NavigationView{
                List{
                    ForEach(properties.properties, id: \.self){property in
                        PropertyCell(property: property)
                    }
                }
                .navigationBarTitle("Properties - \(properties.name)", displayMode: .inline)
                .navigationBarHidden(sizeClass == .compact)
            }
            .environmentObject(properties)
            .environmentObject(script)
        }
    }
}

struct PropertyCell: View{
    @State var newPropertyValue: Array<OrderedDict> = []
    @EnvironmentObject var properties: PropertyInfoArray
    @EnvironmentObject var scriptData: ScriptFile
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
            .environmentObject(scriptData)
            .onAppear(){
                self.newPropertyValue = property.value
                if property.name == "Source"{
                    print(property.value[0].value)
                    scriptData.file = property.value[0].value
                }
            }
            .onChange(of: property.value){_ in
                self.newPropertyValue = property.value
                if property.name == "Source"{
                    print(property.value[0].value)
                    scriptData.file = property.value[0].value
                }
            }
        }
    }
}
