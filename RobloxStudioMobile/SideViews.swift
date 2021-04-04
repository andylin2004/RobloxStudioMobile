//
//  SideViews.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI

struct ListView: View{
    var body: some View{
        SideElementView(content: {
            List{
                Text("Pikachu")
                Text("Raichu")
                Text("Gorochu")
            }
        }, title: "List")
    }
}

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
        }){
            Text(child.name)
                .foregroundColor(Color(UIColor.label))
        }
        .environmentObject(propertyInfo)
    }
}

struct SideViews_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
