import SwiftUI
import SceneKit

struct EditingView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var project: StudioProject
    @State private var panel = "Explorer"
    @State private var showExporter = false
    @State private var showScript = false
    @State private var exportURL: URL?

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            GeometryReader { geo in
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        panelHeader("Explorer")
                        List {
                            Section(header: Text("Workspace")) {
                                ForEach(project.nodes.filter { $0.service == "Workspace" }) { node in
                                    nodeRow(node)
                                }
                            }
                            Section(header: Text("ServerScriptService")) {
                                ForEach(project.nodes.filter { $0.service == "ServerScriptService" }) { node in
                                    nodeRow(node)
                                }
                            }
                        }.listStyle(PlainListStyle())
                    }.frame(width: max(175, geo.size.width * 0.22))
                    Divider()
                    VStack(spacing: 0) {
                        HStack {
                            Text(project.name + "  •  Place").font(.system(size: 12, weight: .semibold))
                            Spacer()
                            Text("3D VIEW").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                        }.padding(9).background(Color.black.opacity(0.12))
                        StudioViewport(project: project)
                    }
                    Divider()
                    inspector.frame(width: max(205, geo.size.width * 0.24))
                }
            }
            bottomBar
        }
        .background(Color(red: 0.13, green: 0.14, blue: 0.16))
        .preferredColorScheme(.dark)
        .fileExporter(isPresented: $showExporter, document: RBXLXExportDocument(text: project.exportXML()), contentType: .rbxlx, defaultFilename: project.name + ".rbxlx") { _ in }
        .sheet(isPresented: $showScript) {
            NavigationView {
                VStack(alignment: .leading) {
                    Text("Script Source").font(.headline).padding(.horizontal)
                    TextEditor(text: Binding(
                        get: { selectedNode?.source ?? "" },
                        set: { value in project.updateSelected { $0.source = value } }
                    )).font(.system(.body, design: .monospaced))
                }
                .navigationBarTitle("Script Editor", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") { showScript = false })
            }.preferredColorScheme(.dark)
        }
    }

    private var selectedNode: StudioNode? { project.nodes.first { $0.id == project.selectedID } }

    private var toolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                Button("Done") { presentationMode.wrappedValue.dismiss() }
                Divider().frame(height: 22)
                ForEach(["Home", "Model", "Test", "View"], id: \.self) { tab in
                    Button(tab) { project.activeTab = tab }
                        .foregroundColor(project.activeTab == tab ? .white : .gray)
                }
                Divider().frame(height: 22)
                Button { project.addPart() } label: { Label("Part", systemImage: "cube") }
                Button { project.addScript(); showScript = true } label: { Label("Script", systemImage: "curlybraces") }
                Button { showExporter = true } label: {
                    Label("Export .RBXLX", systemImage: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.horizontal, 10).padding(.vertical, 7)
                        .background(Color.blue).cornerRadius(6)
                }
            }.font(.system(size: 13, weight: .semibold)).padding(.horizontal, 12).padding(.vertical, 10)
        }.background(Color(red: 0.10, green: 0.11, blue: 0.13))
    }

    private var inspector: some View {
        VStack(alignment: .leading, spacing: 0) {
            panelHeader("Properties")
            if let node = selectedNode {
                Form {
                    Section(header: Text("Instance")) {
                        TextField("Name", text: Binding(get: { selectedNode?.name ?? "" }, set: { v in project.updateSelected { $0.name = v } }))
                        HStack { Text("Class"); Spacer(); Text(node.className).foregroundColor(.secondary) }
                    }
                    if node.className == "Part" {
                        Section(header: Text("Transform")) {
                            numberField("Position X", value: \StudioNode.x)
                            numberField("Position Y", value: \StudioNode.y)
                            numberField("Position Z", value: \StudioNode.z)
                        }
                        Section(header: Text("Size")) {
                            numberField("Width", value: \StudioNode.width)
                            numberField("Height", value: \StudioNode.height)
                            numberField("Depth", value: \StudioNode.depth)
                            Toggle("Anchored", isOn: Binding(get: { selectedNode?.anchored ?? true }, set: { v in project.updateSelected { $0.anchored = v } }))
                        }
                    }
                    if node.className == "Script" || node.className == "LocalScript" {
                        Button("Edit Source") { showScript = true }
                    }
                    Button(role: .destructive) {
                        project.nodes.removeAll { $0.id == node.id }
                        project.selectedID = nil
                    } label: { Label("Delete", systemImage: "trash") }
                }.font(.system(size: 12))
            } else {
                Spacer()
                Text("No Element Selected").font(.system(size: 15, weight: .semibold)).frame(maxWidth: .infinity)
                Spacer()
            }
        }
    }

    private func numberField(_ title: String, value: WritableKeyPath<StudioNode, Double>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", text: Binding(
                get: { String(project.nodes.first(where: { $0.id == project.selectedID })?[keyPath: value] ?? 0) },
                set: { text in if let v = Double(text) { project.updateSelected { $0[keyPath: value] = v } } }
            )).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 70)
        }
    }

    private func panelHeader(_ title: String) -> some View {
        HStack { Text(title).font(.system(size: 12, weight: .bold)); Spacer(); Image(systemName: "ellipsis") }
            .padding(10).background(Color.black.opacity(0.2))
    }

    private func nodeRow(_ node: StudioNode) -> some View {
        Button { project.selectedID = node.id } label: {
            HStack(spacing: 7) {
                Image(systemName: node.className == "Script" ? "doc.text" : "cube")
                    .foregroundColor(node.className == "Script" ? .orange : .blue)
                Text(node.name).lineLimit(1)
                Spacer()
            }.font(.system(size: 12))
                .padding(.vertical, 2)
                .background(project.selectedID == node.id ? Color.blue.opacity(0.25) : Color.clear)
        }.buttonStyle(PlainButtonStyle())
    }

    private var bottomBar: some View {
        HStack {
            Text("Ready").foregroundColor(.green)
            Spacer()
            Text("\(project.nodes.count) instances")
            Text("  •  iPad Studio")
        }.font(.system(size: 10, weight: .medium)).padding(8).background(Color.black.opacity(0.25))
    }
}
