import SwiftUI
import SceneKit
import UniformTypeIdentifiers

struct EditingView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var project: StudioProject
    @State private var showExporter = false
    @State private var showScript = false
    @State private var showAnimationPanel = false
    @State private var toolboxSearch = ""
    @State private var toolboxTab = "Models"
    @State private var commandText = ""
    @State private var showR6Importer = false
    @State private var importStatus = ""

    private var selectedNode: StudioNode? { project.selectedNode }

    var body: some View {
        VStack(spacing: 0) {
            topToolbar
            ribbon
            Divider()
            GeometryReader { geo in
                HStack(spacing: 0) {
                    toolbox.frame(width: max(190, geo.size.width * 0.225))
                    Divider()
                    VStack(spacing: 0) {
                        HStack {
                            Text(project.name + "  •  Workspace").font(.system(size: 12, weight: .semibold))
                            Spacer()
                            Text("3D VIEW").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                        }.padding(9).background(Color(red: 0.94, green: 0.95, blue: 0.97))
                        ZStack(alignment: .bottom) {
                            StudioViewport(project: project)
                            HStack(alignment: .bottom) {
                                TouchJoystick(title: "MOVE") { vector in
                                    project.moveViewport(-Double(vector.x) * 0.42, Double(vector.y) * 0.42)
                                }
                                Spacer()
                                TouchJoystick(title: "LOOK") { vector in
                                    project.rotateViewport(Double(vector.x) * 0.035, Double(vector.y) * 0.025)
                                }
                            }.padding(18)
                        }
                    }
                    Divider()
                    VStack(spacing: 0) {
                        explorer
                        Divider()
                        inspector
                    }.frame(width: max(230, geo.size.width * 0.235))
                }
            }
            commandBar
        }
        .background(Color(red: 0.91, green: 0.93, blue: 0.96))
        .preferredColorScheme(.light)
        .fileExporter(isPresented: $showExporter, document: binaryDocument, contentType: UTType(filenameExtension: "rbxl") ?? .data, defaultFilename: project.name + ".rbxl") { _ in }
        .sheet(isPresented: $showScript) {
            NavigationView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedNode?.name ?? "Script Source").font(.headline).padding(.horizontal)
                    TextEditor(text: Binding(
                        get: { selectedNode?.source ?? "" },
                        set: { value in project.updateSelected { $0.source = value } }
                    )).font(.system(.body, design: .monospaced))
                }
                .navigationBarTitle("Luau Editor", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") { showScript = false })
            }.preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showAnimationPanel) { animationSheet }
        .fileImporter(isPresented: $showR6Importer, allowedContentTypes: [UTType(filenameExtension: "obj") ?? .plainText, .png], allowsMultipleSelection: true) { result in
            importR6Character(result)
        }
        .alert(isPresented: Binding(get: { !importStatus.isEmpty }, set: { if !$0 { importStatus = "" } })) {
            Alert(title: Text("R6 Character Import"), message: Text(importStatus), dismissButton: .default(Text("OK")))
        }
    }

    private func importR6Character(_ result: Result<[URL], Error>) {
        do {
            let urls = try result.get()
            var objFiles: [(String, String)] = []
            var textureData: Data?
            for url in urls {
                let scoped = url.startAccessingSecurityScopedResource()
                defer { if scoped { url.stopAccessingSecurityScopedResource() } }
                let ext = url.pathExtension.lowercased()
                if ext == "obj" {
                    objFiles.append((url.deletingPathExtension().lastPathComponent, try String(contentsOf: url, encoding: .utf8)))
                } else if ext == "png" { textureData = try Data(contentsOf: url) }
            }
            guard !objFiles.isEmpty else { importStatus = "Select the six BaconHair_Slice OBJ files and the character texture PNG together."; return }
            objFiles.sort { $0.0.localizedStandardCompare($1.0) == .orderedAscending }
            project.nodes.removeAll { $0.className == "MeshPart" && $0.name.hasPrefix("BaconHair_") }
            for (name, source) in objFiles {
                project.nodes.append(StudioNode(name: name, className: "MeshPart", meshOBJ: source, meshTextureData: textureData))
            }
            project.selectedID = project.nodes.last(where: { $0.className == "MeshPart" })?.id
            project.cameraTargetX = 0
            project.cameraTargetZ = 0
            if textureData == nil {
                importStatus = "Imported \(objFiles.count) OBJ mesh sections. No PNG was selected, so a fallback material is used. Import the atlas PNG together with the OBJ files to apply the character artwork."
            } else {
                importStatus = "Imported \(objFiles.count) OBJ mesh sections and applied the texture atlas. The sections remain separately selectable in Explorer."
            }
        } catch { importStatus = "Import failed: \(error.localizedDescription)" }
    }
    private var binaryDocument: RBXLBinaryExportDocument {
        do { return RBXLBinaryExportDocument(data: try project.exportBinaryRBXL()) }
        catch { return RBXLBinaryExportDocument(data: Data()) }
    }

    private var topToolbar: some View {
        HStack(spacing: 14) {
            Button { presentationMode.wrappedValue.dismiss() } label: { Image(systemName: "line.3.horizontal").font(.system(size: 19, weight: .semibold)) }.foregroundColor(.primary)
            Image(systemName: "cube.fill").font(.system(size: 25)).foregroundColor(Color(red: 0.0, green: 0.42, blue: 0.95))
            ForEach(["Home", "Model", "Test", "View", "Plugins"], id: \.self) { tab in
                Button(tab) { project.activeTab = tab }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(project.activeTab == tab ? .white : .primary)
                    .padding(.horizontal, 17).padding(.vertical, 10)
                    .background(project.activeTab == tab ? Color.blue : Color.clear).cornerRadius(9)
            }
            Spacer(minLength: 4)
            Button { showR6Importer = true } label: {
                Label("Import R6", systemImage: "person.crop.square.badge.plus").font(.system(size: 13, weight: .bold)).foregroundColor(.blue)
            }
            Button { showExporter = true } label: {
                Label("Export .rbxl", systemImage: "square.and.arrow.up")
                    .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 13).padding(.vertical, 10).background(Color.blue).cornerRadius(9)
            }
            Button { project.duplicateSelected() } label: { Image(systemName: "arrow.uturn.backward") }.foregroundColor(.secondary)
            Button { project.deleteSelected() } label: { Image(systemName: "arrow.uturn.forward") }.foregroundColor(.secondary)
        }.padding(.horizontal, 12).padding(.vertical, 7)
            .background(Color(red: 0.96, green: 0.97, blue: 0.99))
    }

    private var ribbon: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ribbonGroup("Clipboard", items: [("Paste", "doc.on.clipboard"), ("Cut", "scissors"), ("Copy", "doc.on.doc"), ("Duplicate", "plus.square.on.square")]) { project.duplicateSelected() }
                ribbonGroup("Tools", items: [("Select", "cursorarrow"), ("Move", "move.3d"), ("Scale", "arrow.up.left.and.arrow.down.right"), ("Rotate", "rotate.3d")]) {}
                ribbonGroup("Insert", items: [("Part", "cube.fill"), ("Terrain", "mountain.2.fill"), ("Insert Object", "plus")]) { project.addPart(shape: "Block") }
                ribbonGroup("Edit", items: [("Material", "circle.lefthalf.filled"), ("Color", "paintpalette"), ("Anchor", "pin.fill")]) {}
                ribbonGroup("Test", items: [("Play", "play.fill"), ("Stop", "stop.fill"), ("Game Settings", "gearshape"), ("Team Test", "person.3.fill")]) {}
                ribbonGroup("Animation", items: [("Animation Editor", "figure.run")]) { showAnimationPanel = true }
            }.padding(.horizontal, 5).padding(.vertical, 5)
        }.frame(height: 86).background(Color(red: 0.94, green: 0.95, blue: 0.97))
    }

    private func ribbonGroup(_ title: String, items: [(String, String)], action: @escaping () -> Void) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 12) {
                ForEach(items, id: \.0) { item in
                    Button(action: action) {
                        VStack(spacing: 4) {
                            Image(systemName: item.1).font(.system(size: 23, weight: .medium)).foregroundColor(.blue)
                            Text(item.0).font(.system(size: 10, weight: .medium)).foregroundColor(.primary).lineLimit(1)
                        }.frame(minWidth: 47)
                    }.buttonStyle(PlainButtonStyle())
                }
            }.padding(.horizontal, 9)
            Text(title).font(.system(size: 9)).foregroundColor(.secondary)
        }.padding(.horizontal, 7)
            .overlay(Rectangle().fill(Color.gray.opacity(0.22)).frame(width: 1).padding(.vertical, 5), alignment: .trailing)
    }

    private var toolbox: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Toolbox").font(.system(size: 16, weight: .bold))
                Spacer()
                Image(systemName: "lock").font(.system(size: 13))
                Image(systemName: "chevron.left.2").font(.system(size: 13)).padding(.leading, 8)
            }.padding(10)
            HStack {
                TextField("Search models...", text: $toolboxSearch).font(.system(size: 13))
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
            }.padding(9).background(Color.white).cornerRadius(7).padding(.horizontal, 8).padding(.bottom, 8)
            HStack(spacing: 4) {
                ForEach(["Models", "Decals", "Plugins"], id: \.self) { tab in
                    Button(tab) { toolboxTab = tab }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(toolboxTab == tab ? .white : .primary)
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(toolboxTab == tab ? Color.blue : Color.gray.opacity(0.12)).cornerRadius(6)
                }
            }.padding(.horizontal, 8).padding(.bottom, 8)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 7) {
                    ForEach(toolboxItems.filter { toolboxSearch.isEmpty || $0.0.localizedCaseInsensitiveContains(toolboxSearch) }, id: \.0) { item in
                        Button {
                            switch item.0 {
                            case "Sphere": project.addPart(shape: "Sphere")
                            case "Cylinder": project.addPart(shape: "Cylinder")
                            case "Wedge": project.addPart(shape: "Wedge")
                            default: project.addPart(shape: "Block")
                            }
                        } label: {
                            VStack(spacing: 5) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color(red: 0.91, green: 0.94, blue: 0.98))
                                    Image(systemName: item.1).font(.system(size: 31)).foregroundColor(item.2)
                                }.frame(height: 66)
                                Text(item.0).font(.system(size: 10, weight: .medium)).foregroundColor(.primary).lineLimit(1)
                            }.padding(5).background(Color.white).cornerRadius(6)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }.padding(7)
            }
        }.background(Color(red: 0.93, green: 0.95, blue: 0.98))
    }

    private var toolboxItems: [(String, String, Color)] {
        [("Block", "cube.fill", .gray), ("Sphere", "circle.fill", .gray), ("Cylinder", "cylinder.fill", .gray),
         ("Wedge", "triangle.fill", .gray), ("Corner Wedge", "triangle", .gray), ("Truss", "square.grid.3x3", .gray),
         ("Tree", "tree.fill", .green), ("House", "house.fill", Color(red: 0.55, green: 0.34, blue: 0.20)), ("Car", "car.fill", .red),
         ("R6 Rig", "figure.stand", .blue), ("R15 Rig", "figure.walk", .green), ("NPC", "person.fill", .orange)]
    }

    private var explorer: some View {
        VStack(spacing: 0) {
            panelHeader("Explorer")
            List {
                ForEach(project.services, id: \.self) { service in
                    Section(header: Text(service).font(.system(size: 11, weight: .bold))) {
                        ForEach(project.nodes.filter { $0.service == service }) { node in
                            nodeRow(node)
                        }
                    }
                }
            }.listStyle(PlainListStyle())
        }
    }

    private var inspector: some View {
        VStack(alignment: .leading, spacing: 0) {
            panelHeader("Properties")
            if let node = selectedNode {
                Form {
                    Section(header: Text("Instance")) {
                        TextField("Name", text: Binding(get: { selectedNode?.name ?? "" }, set: { value in project.updateSelected { $0.name = value } }))
                        HStack { Text("Class"); Spacer(); Text(node.className).foregroundColor(.secondary) }
                        if node.className == "Part" {
                            Picker("Shape", selection: Binding(get: { selectedNode?.shape ?? "Block" }, set: { value in project.updateSelected { $0.shape = value } })) {
                                Text("Block").tag("Block")
                                Text("Sphere").tag("Sphere")
                                Text("Cylinder").tag("Cylinder")
                                Text("Wedge").tag("Wedge")
                            }
                        }
                    }
                    if node.className == "Part" {
                        Section(header: Text("Transform")) {
                            numberField("Position X", keyPath: \.x)
                            numberField("Position Y", keyPath: \.y)
                            numberField("Position Z", keyPath: \.z)
                        }
                        Section(header: Text("Size")) {
                            numberField("Width", keyPath: \.width)
                            numberField("Height", keyPath: \.height)
                            numberField("Depth", keyPath: \.depth)
                            Toggle("Anchored", isOn: Binding(get: { selectedNode?.anchored ?? true }, set: { value in project.updateSelected { $0.anchored = value } }))
                            Toggle("Can Collide", isOn: Binding(get: { selectedNode?.canCollide ?? true }, set: { value in project.updateSelected { $0.canCollide = value } }))
                            numberField("Transparency", keyPath: \.transparency)
                        }
                    }
                    if ["Script", "LocalScript", "ModuleScript"].contains(node.className) {
                        Button("Edit Source") { showScript = true }
                    }
                    Button(action: { project.deleteSelected() }) {
                        Label("Delete Instance", systemImage: "trash").foregroundColor(.red)
                    }
                }.font(.system(size: 12))
            } else {
                Spacer()
                Text("Select an object").font(.system(size: 13, weight: .semibold)).frame(maxWidth: .infinity)
                Spacer()
            }
        }
    }

    private var animationSheet: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Animation Editor").font(.title2.bold())
                Text("Animation timeline workspace").foregroundColor(.secondary)
                HStack {
                    Text("00:00")
                    Spacer()
                    Text("00:10")
                }.font(.caption.monospacedDigit())
                GeometryReader { geometry in
                    VStack(spacing: 8) {
                        Rectangle().fill(Color.blue.opacity(0.7)).frame(height: 3)
                        HStack(spacing: 4) {
                            ForEach(0..<20, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 3).fill(index % 4 == 0 ? Color.orange : Color.gray.opacity(0.35)).frame(height: 28)
                            }
                        }
                        Text("Add a compatible rig to begin creating animation tracks.")
                            .font(.caption).foregroundColor(.secondary)
                    }.frame(width: geometry.size.width, alignment: .leading)
                }
                Spacer()
            }.padding()
            .navigationBarTitle("Animation", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") { showAnimationPanel = false })
        }.preferredColorScheme(.dark)
    }

    private func numberField(_ title: String, keyPath: WritableKeyPath<StudioNode, Double>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", text: Binding(
                get: { String(project.selectedNode?[keyPath: keyPath] ?? 0) },
                set: { text in if let value = Double(text) { project.updateSelected { $0[keyPath: keyPath] = value } } }
            )).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 76)
        }
    }

    private func toolButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).frame(width: 22)
                Text(title).lineLimit(1)
                Spacer(minLength: 0)
            }.font(.system(size: 12, weight: .medium)).padding(8)
                .background(Color.white.opacity(0.06)).cornerRadius(5)
        }.buttonStyle(PlainButtonStyle())
    }

    private func panelHeader(_ title: String) -> some View {
        HStack { Text(title).font(.system(size: 12, weight: .bold)); Spacer(); Image(systemName: "ellipsis") }
            .padding(10).background(Color(red: 0.91, green: 0.93, blue: 0.96))
    }

    private func nodeRow(_ node: StudioNode) -> some View {
        Button { project.selectedID = node.id } label: {
            HStack(spacing: 7) {
                Image(systemName: node.className.contains("Script") ? "doc.text" : "cube")
                    .foregroundColor(node.className.contains("Script") ? .orange : .blue)
                Text(node.name).lineLimit(1)
                Spacer()
            }.font(.system(size: 11))
                .padding(.vertical, 2)
                .background(project.selectedID == node.id ? Color.blue.opacity(0.25) : Color.clear)
        }.buttonStyle(PlainButtonStyle())
    }

    private var commandBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
            TextField("Run a command", text: $commandText).font(.system(size: 12))
            Spacer()
        }.padding(.horizontal, 10).padding(.vertical, 9)
            .background(Color(red: 0.97, green: 0.98, blue: 0.99))
            .overlay(Rectangle().fill(Color.gray.opacity(0.25)).frame(height: 1), alignment: .top)
    }
}

private struct TouchJoystick: View {
    let title: String
    let onMove: (CGPoint) -> Void
    @State private var offset: CGSize = .zero
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle().fill(Color.black.opacity(0.34)).overlay(Circle().stroke(Color.white.opacity(0.65), lineWidth: 2)).frame(width: 104, height: 104)
                Circle().stroke(Color.white.opacity(0.24), lineWidth: 1).frame(width: 64, height: 64)
                Circle().fill(Color.white.opacity(0.78)).overlay(Circle().stroke(Color.black.opacity(0.16), lineWidth: 1)).frame(width: 42, height: 42).shadow(color: .black.opacity(0.25), radius: 4, y: 2).offset(offset)
            }
            Text(title).font(.system(size: 9, weight: .bold)).foregroundColor(.white).shadow(color: .black.opacity(0.8), radius: 2)
        }
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { value in
                let radius: CGFloat = 38
                let dx = max(-1, min(1, value.translation.width / radius))
                let dy = max(-1, min(1, value.translation.height / radius))
                offset = CGSize(width: dx * radius, height: dy * radius)
                onMove(CGPoint(x: dx, y: dy))
            }
            .onEnded { _ in offset = .zero; onMove(.zero) })
    }
}
