//
//  ContentView.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            List{
                NavigationLink(destination: ExploreView()){
                    Label("Explore", systemImage: "house")
                }
                NavigationLink(destination: FileView()){
                    Label("Files", systemImage: "folder")
                }
                NavigationLink(
                    destination: SettingView(),
                    label: {
                        Label("Settings", systemImage: "gear")
                    })
                NavigationLink(
                    destination: EditingView()
                        .navigationBarHidden(true),
                    label: {
                        Text("Dev")
                    })
                Section(header: Text("Favorites")){
                    
                }
            }.listStyle(SidebarListStyle())
            .navigationTitle("Home")
            .toolbar{
                EditButton()
            }
            ExploreView()
        }
    }
}

struct ExploreView: View{
    var body: some View{
        Text("Explore placeholder")
            .navigationTitle("Explore")
    }
}

struct FileView: View{
    var body: some View{
        Text("Files placeholder")
            .navigationTitle("Files")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "plus")
                    })
                }
            }
    }
}

struct SettingView: View{
    var body: some View{
        Text("Settings placeholder")
            .navigationTitle("Settings")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
