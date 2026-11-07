import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedSection = "New"
    @State private var project: StudioProject? = nil
    @State private var showPlaceImporter = false
    @State private var importMessage = ""
    private let templates = ["Baseplate", "Classic Baseplate", "Flat Terrain", "Obby", "Starting Place", "Village", "Castle", "City"]

    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                sidebar
                VStack(spacing: 0) {
                    HStack {
                        Text("FILE").font(.system(size: 13, weight: .bold))
                        Spacer()
                        Text("RobloxStudioMobile").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                        Button { showPlaceImporter = true } label: { Label("Open .rbxlx", systemImage: "folder").font(.system(size: 12, weight: .bold)).padding(8).background(Color.blue).cornerRadius(7) }.foregroundColor(.white)
                    }
                    .padding(.horizontal, 22).padding(.vertical, 15)
                    Divider()
                    if selectedSection == "New" {
                        templatePage
                    } else if selectedSection == "My Games" {
                        VStack(spacing: 12) {
                            Image(systemName: "folder").font(.system(size: 42)).foregroundColor(.secondary)
                            Text("Your projects will appear here").foregroundColor(.secondary)
                            Button { selectedSection = "New" } label: { Text("Create a project").font(.system(size: 14, weight: .semibold)).foregroundColor(.white).padding(.horizontal, 16).padding(.vertical, 10).background(Color.blue).cornerRadius(8) }.buttonStyle(PlainButtonStyle())
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack { Image(systemName: "clock").font(.largeTitle); Text("No recent projects yet").foregroundColor(.secondary) }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .background(Color(red: 0.12, green: 0.13, blue: 0.15))
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(item: $project) { selectedProject in
            EditingView(project: selectedProject)
        }
        .preferredColorScheme(.dark)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("STUDIO").font(.system(size: 11, weight: .bold)).foregroundColor(.gray).padding(.horizontal, 14).padding(.top, 24)
            sidebarButton("New", icon: "plus.square.fill")
            sidebarButton("My Games", icon: "gamecontroller.fill")
            sidebarButton("Recent", icon: "clock")
            sidebarButton("Archive", icon: "archivebox")
            Spacer()
            sidebarButton("Settings", icon: "gearshape")
        }
        .frame(width: 112)
        .background(Color(red: 0.09, green: 0.10, blue: 0.12))
    }

    private func sidebarButton(_ title: String, icon: String) -> some View {
        Button { selectedSection = title } label: {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 20))
                Text(title).font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(selectedSection == title ? .white : .gray)
            .frame(maxWidth: .infinity).padding(.vertical, 12)
            .background(selectedSection == title ? Color.blue.opacity(0.55) : Color.clear)
            .cornerRadius(8)
        }.buttonStyle(PlainButtonStyle()).padding(.horizontal, 8)
    }

    private var templatePage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("All Templates").font(.system(size: 24, weight: .bold))
                    Spacer()
                    Text("Choose a starting place").font(.system(size: 13)).foregroundColor(.secondary)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(["All Templates", "Theme", "Gameplay"], id: \.self) { tab in
                            Text(tab).font(.system(size: 13, weight: .semibold))
                                .padding(.horizontal, 15).padding(.vertical, 9)
                                .background(tab == "All Templates" ? Color.blue : Color.gray.opacity(0.18))
                                .cornerRadius(6)
                        }
                    }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 14)], spacing: 16) {
                    ForEach(templates, id: \.self) { template in
                        Button {
                            project = StudioProject(name: template == "Baseplate" ? "Place1" : template, template: template == "Classic Baseplate" ? "Baseplate" : template)
                        } label: {
                            VStack(alignment: .leading, spacing: 7) {
                                ZStack {
                                    LinearGradient(gradient: Gradient(colors: [Color(red: 0.35, green: 0.65, blue: 0.88), Color(red: 0.23, green: 0.31, blue: 0.43)]), startPoint: .top, endPoint: .bottom)
                                    Image(systemName: template == "Obby" ? "square.stack.3d.up.fill" : "cube.transparent")
                                        .font(.system(size: 38)).foregroundColor(.white.opacity(0.9))
                                    Image(systemName: "square.grid.3x3").font(.system(size: 45)).foregroundColor(.white.opacity(0.22)).offset(y: 24)
                                }.frame(height: 100).clipped().cornerRadius(5)
                                Text(template).font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                            }
                            .padding(8).background(Color.white.opacity(0.07)).cornerRadius(7)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }.padding(22)
        }
    }
}
