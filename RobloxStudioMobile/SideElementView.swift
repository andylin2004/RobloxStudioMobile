//
//  SideElementView.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI

struct SideElementView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content
    let title: String
    
    init(@ViewBuilder content: @escaping () -> Content, title: String){
        self.content = content()
        self.title = title
    }
    
    var body: some View{
        VStack{
            ZStack{
                Rectangle()
                    .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                    .frame(height: 30)
                HStack{
                    Button(action: {}, label: {
                        Circle()
                            .foregroundColor(Color.red)
                            .frame(width: 20, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .padding(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    })
                    Spacer()
                    Text(title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(UIColor.systemGray))
                        .padding(.trailing, 10)
                    Spacer()
                }
            }.padding(/*@START_MENU_TOKEN@*/.bottom/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/-5.0/*@END_MENU_TOKEN@*/)
            Divider()
            self.content
        }
    }
    
}

struct SideElementView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
