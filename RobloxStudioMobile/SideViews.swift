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
                Text(child.name)
            }else{
                DisclosureGroup{
                    childView(startChild: child.childStart!, endChild: child.childEnd!, data: data)
                } label: {
                    Text(child.name)
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

struct SideViews_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
