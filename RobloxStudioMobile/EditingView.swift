import SwiftUI
import SceneKit

struct EditingView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var project: StudioProject
    @State private var showExporter = false
    @State private var showScript = false
    @State private var showAnimationPanel = false

    private var selectedNode: StudioNode? { project.selectedNode }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            GeometryReader { geo in
                HStack(spacing: 0) {
                    toolbox.frame(width: max(145, geo.size.width * 0.19))
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
                                    project.rotateViewport(Double(vector.dx) * 0.035, Double(vector.dy) * 0.025)
                                }
                            }.padding(18)
                        }
                    }
                    Divider()
                    VStack(spacing: 0) {
                        explorer
                        Divider()
                        inspector
                    }.frame(width: max(205, geo.size.width * 0.24))
                }
            }
            bottomBar
        }
        .background(Color(red: 0.91, green: 0.93, blue: 0.96))
        .preferredColorScheme(.light)
        .fileExporter(isPresented: $showExporter, document: RBXLXExportDocument(text: project.exportXML()), contentType: .rbxlx, defaultFilename: project.name + ".rbxlx") { _ in }
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
    }

    private var toolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 13) {
                Button("Done") { presentationMode.wrappedValue.dismiss() }
                Divider().frame(height: 24)
                ForEach(["Home", "Model", "Test", "View"], id: \.self) { tab in
                    Button(tab) { project.activeTab = tab }
                        .foregroundColor(project.activeTab == tab ? .white : .gray)
                }
                Divider().frame(height: 24)
                Menu {
                    Button("Block") { project.addPart(shape: "Block") }
                    Button("Sphere") { project.addPart(shape: "Sphere") }
                    Button("Cylinder") { project.addPart(shape: "Cylinder") }
                    Button("Wedge") { project.addPart(shape: "Wedge") }
                } label: { Label("Add Part", systemImage: "cube").font(.system(size: 13, weight: .semibold)) }
                Menu {
                    Button("Script") { project.addScript(kind: "Script"); showScript = true }
                    Button("LocalScript") { project.addScript(kind: "LocalScript"); showScript = true }
                    Button("ModuleScript") { project.addScript(kind: "ModuleScript"); showScript = true }
                } label: { Label("Script", systemImage: "curlybraces").font(.system(size: 13, weight: .semibold)) }
                Button { project.duplicateSelected() } label: { Label("Duplicate", systemImage: "plus.square.on.square") }
                    .disabled(selectedNode == nil)
                Button { project.deleteSelected() } label: { Label("Delete", systemImage: "trash") }
                    .disabled(selectedNode == nil)
                Button { showAnimationPanel = true } label: { Label("Animation", systemImage: "figure.run") }
                Button { showExporter = true } label: {
                    Label("Export .RBXLX", systemImage: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.horizontal, 10).padding(.vertical, 7)
                        .background(Color.blue).cornerRadius(6)
                }
            }.font(.system(size: 13, weight: .semibold)).padding(.horizontal, 12).padding(.vertical, 9)
        }.background(Color(red: 0.96, green: 0.97, blue: 0.99))
    }

    private var toolbox: some View {
        VStack(alignment: .leading, spacing: 0) {
            panelHeader("Toolbox")
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("CREATE").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                    toolButton("Block", icon: "cube") { project.addPart(shape: "Block") }
                    toolButton("Sphere", icon: "circle") { project.addPart(shape: "Sphere") }
                    toolButton("Cylinder", icon: "cylinder") { project.addPart(shape: "Cylinder") }
                    toolButton("Wedge", icon: "triangle") { project.addPart(shape: "Wedge") }
                    Divider()
                    Text("SCRIPTS").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                    toolButton("Script", icon: "doc.text") { project.addScript(kind: "Script"); showScript = true }
                    toolButton("LocalScript", icon: "iphone") { project.addScript(kind: "LocalScript"); showScript = true }
                    toolButton("ModuleScript", icon: "shippingbox") { project.addScript(kind: "ModuleScript"); showScript = true }
                    Divider()
                    Text("EDIT").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                    toolButton("Duplicate", icon: "plus.square.on.square") { project.duplicateSelected() }
                    toolButton("Delete", icon: "trash") { project.deleteSelected() }
                }.padding(10)
            }
        }.background(Color.black.opacity(0.12))
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

    private var bottomBar: some View {
        HStack {
            Text("Ready").foregroundColor(.green)
            Spacer()
            Text("\(project.nodes.count) instances")
            Text(" • iPad Studio")
        }.font(.system(size: 10, weight: .medium)).padding(8).background(Color(red: 0.94, green: 0.95, blue: 0.97))
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
