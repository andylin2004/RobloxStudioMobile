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

struct SideViews_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
