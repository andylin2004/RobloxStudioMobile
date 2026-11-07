import Foundation
import SwiftUI
import SceneKit
import UIKit

struct StudioNode: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var className: String
    var shape: String = "Block"
    var x: Double = 0
    var y: Double = 3
    var z: Double = 0
    var width: Double = 4
    var height: Double = 1
    var depth: Double = 4
    var anchored: Bool = true
    var canCollide: Bool = true
    var transparency: Double = 0
    var source: String = ""
    var service: String = "Workspace"
    var meshOBJ: String = ""
    var meshTextureData: Data? = nil
    var materialColor: String = ""
}

final class StudioProject: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String
    @Published var nodes: [StudioNode] = []
    @Published var selectedID: UUID?
    @Published var activeTab = "Home"
    @Published var cameraTargetX: Double = 0
    @Published var cameraTargetZ: Double = 0
    @Published var cameraYaw: Double = 0.735
    @Published var cameraPitch: Double = 0
    @Published var isPlaying = false
    @Published var playerOffsetX: Double = 0
    @Published var playerOffsetZ: Double = 0

    func moveViewport(_ x: Double, _ z: Double) {
        cameraTargetX += x
        cameraTargetZ += z
    }

    func rotateViewport(_ x: Double, _ y: Double) {
        cameraYaw += x
        cameraPitch = min(0.85, max(-0.45, cameraPitch + y))
    }

    let services = ["Workspace", "Players", "Lighting", "ReplicatedStorage", "ServerScriptService", "ServerStorage", "StarterGui", "StarterPack", "StarterPlayer", "SoundService", "Teams"]

    init(name: String = "Untitled", template: String = "Baseplate") {
        self.name = name
        switch template {
        case "Obby":
            nodes = [
                StudioNode(name: "Baseplate", className: "Part", x: 0, y: -1, width: 120, height: 2, depth: 120),
                StudioNode(name: "StartPlatform", className: "Part", x: 0, y: 2, width: 14, height: 2, depth: 14),
                StudioNode(name: "Jump1", className: "Part", x: 0, y: 4, z: -18, width: 8, height: 2, depth: 8),
                StudioNode(name: "Jump2", className: "Part", x: 10, y: 6, z: -32, width: 8, height: 2, depth: 8),
                StudioNode(name: "Finish", className: "Part", x: 0, y: 8, z: -50, width: 16, height: 2, depth: 16)
            ]
        case "Flat Terrain":
            nodes = [StudioNode(name: "TerrainBase", className: "Part", x: 0, y: -2, width: 512, height: 4, depth: 512)]
        default:
            nodes = [StudioNode(name: "Baseplate", className: "Part", x: 0, y: -1, width: 512, height: 2, depth: 512)]
        }
        addR6Rig()
    }


    func togglePlay() {
        isPlaying.toggle()
        if !isPlaying {
            playerOffsetX = 0
            playerOffsetZ = 0
        }
    }

    func movePlayer(_ x: Double, _ z: Double) {
        guard isPlaying else { return }
        playerOffsetX += x
        playerOffsetZ += z
    }

    func addR6Rig() {
        guard !nodes.contains(where: { $0.name == "R6_Head" }) else { return }
        let rig: [StudioNode] = [
            StudioNode(name: "R6_LeftLeg", className: "Part", x: -0.5, y: 1.1, width: 1, height: 2.2, depth: 1, materialColor: "pants"),
            StudioNode(name: "R6_RightLeg", className: "Part", x: 0.5, y: 1.1, width: 1, height: 2.2, depth: 1, materialColor: "pants"),
            StudioNode(name: "R6_LeftFoot", className: "Part", x: -0.5, y: 0.12, width: 1, height: 0.24, depth: 1.05, materialColor: "white"),
            StudioNode(name: "R6_RightFoot", className: "Part", x: 0.5, y: 0.12, width: 1, height: 0.24, depth: 1.05, materialColor: "white"),
            StudioNode(name: "R6_Torso", className: "Part", x: 0, y: 3.25, width: 2, height: 2.1, depth: 1, materialColor: "blue"),
            StudioNode(name: "R6_JacketLeft", className: "Part", x: -0.76, y: 3.25, width: 0.48, height: 2.1, depth: 1.04, materialColor: "black"),
            StudioNode(name: "R6_JacketRight", className: "Part", x: 0.76, y: 3.25, width: 0.48, height: 2.1, depth: 1.04, materialColor: "black"),
            StudioNode(name: "R6_LeftArm", className: "Part", x: -1.55, y: 3.25, width: 1, height: 2.1, depth: 1, materialColor: "black"),
            StudioNode(name: "R6_RightArm", className: "Part", x: 1.55, y: 3.25, width: 1, height: 2.1, depth: 1, materialColor: "black"),
            StudioNode(name: "R6_Head", className: "Part", x: 0, y: 5.15, width: 2, height: 1.55, depth: 1.35, materialColor: "white"),
            StudioNode(name: "R6_LeftEye", className: "Part", shape: "Sphere", x: -0.36, y: 5.28, z: 0.69, width: 0.16, height: 0.3, depth: 0.12, materialColor: "face"),
            StudioNode(name: "R6_RightEye", className: "Part", shape: "Sphere", x: 0.36, y: 5.28, z: 0.69, width: 0.16, height: 0.3, depth: 0.12, materialColor: "face"),
            StudioNode(name: "R6_Smile", className: "Part", x: 0, y: 4.82, z: 0.70, width: 0.62, height: 0.055, depth: 0.035, materialColor: "face"),
            StudioNode(name: "R6_HairCap", className: "Part", x: 0, y: 6.05, z: 0, width: 2.15, height: 0.58, depth: 1.48, materialColor: "hairDark"),
            StudioNode(name: "R6_HairFront1", className: "Part", x: -0.78, y: 5.75, z: 0.48, width: 0.42, height: 0.9, depth: 0.5, materialColor: "hair"),
            StudioNode(name: "R6_HairFront2", className: "Part", x: -0.32, y: 5.78, z: 0.55, width: 0.42, height: 0.95, depth: 0.48, materialColor: "hairLight"),
            StudioNode(name: "R6_HairFront3", className: "Part", x: 0.18, y: 5.78, z: 0.56, width: 0.42, height: 0.92, depth: 0.48, materialColor: "hair"),
            StudioNode(name: "R6_HairFront4", className: "Part", x: 0.65, y: 5.74, z: 0.48, width: 0.42, height: 0.86, depth: 0.5, materialColor: "hairLight"),
            StudioNode(name: "R6_HairSideLeft", className: "Part", x: -1.0, y: 5.25, z: 0.02, width: 0.42, height: 1.5, depth: 1.25, materialColor: "hairDark"),
            StudioNode(name: "R6_HairSideRight", className: "Part", x: 1.0, y: 5.25, z: 0.02, width: 0.42, height: 1.5, depth: 1.25, materialColor: "hairDark")
        ]
        nodes.append(contentsOf: rig)
        selectedID = rig.first(where: { $0.name == "R6_Head" })?.id
    }

    var selectedNode: StudioNode? { nodes.first { $0.id == selectedID } }

    func addPart(shape: String = "Block") {
        let label = shape == "Block" ? "Part" : shape
        let node = StudioNode(name: label, className: "Part", shape: shape, x: Double(nodes.filter { $0.className == "Part" }.count * 3), y: 4)
        nodes.append(node)
        selectedID = node.id
    }

    func addScript(kind: String = "Script") {
        let service = kind == "LocalScript" ? "StarterPlayer" : "ServerScriptService"
        let starter = kind == "ModuleScript" ? "return {}" : "print(\"Hello from RobloxStudioMobile!\")"
        let node = StudioNode(name: kind, className: kind, source: "-- Edit this Luau source\n" + starter, service: service)
        nodes.append(node)
        selectedID = node.id
    }

    func duplicateSelected() {
        guard var copy = selectedNode else { return }
        copy.id = UUID()
        copy.name += " Copy"
        copy.x += 3
        nodes.append(copy)
        selectedID = copy.id
    }

    func deleteSelected() {
        guard let id = selectedID else { return }
        nodes.removeAll { $0.id == id }
        selectedID = nil
    }

    func updateSelected(_ change: (inout StudioNode) -> Void) {
        guard let id = selectedID, let index = nodes.firstIndex(where: { $0.id == id }) else { return }
        change(&nodes[index])
    }

    func exportXML() -> String {
        func esc(_ value: String) -> String {
            value.replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
                .replacingOccurrences(of: "\"", with: "&quot;")
        }
        func number(_ value: Double) -> String { String(format: "%.5f", value) }
        var xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<roblox version=\"4\">\n<External>null</External>\n<External>null</External>\n"
        for (serviceIndex, service) in services.enumerated() {
            xml += "<Item class=\"\(service)\" referent=\"RBX\(serviceIndex)\"><Properties><string name=\"Name\">\(service)</string></Properties>\n"
            for (index, node) in nodes.filter({ $0.service == service }).enumerated() {
                let ref = "RBXOBJ\(serviceIndex)_\(index)"
                xml += "<Item class=\"\(esc(node.className))\" referent=\"\(ref)\"><Properties><string name=\"Name\">\(esc(node.name))</string>"
                if node.className == "Part" {
                    let shapeToken = node.shape == "Sphere" ? 0 : (node.shape == "Cylinder" ? 2 : 1)
                    xml += "<bool name=\"Anchored\">\(node.anchored ? "true" : "false")</bool>"
                    xml += "<bool name=\"CanCollide\">\(node.canCollide ? "true" : "false")</bool>"
                    xml += "<float name=\"Transparency\">\(number(node.transparency))</float>"
                    xml += "<token name=\"Shape\">\(shapeToken)</token>"
                    xml += "<CoordinateFrame name=\"CFrame\"><X>\(number(node.x))</X><Y>\(number(node.y))</Y><Z>\(number(node.z))</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame>"
                    xml += "<Vector3 name=\"size\"><X>\(number(node.width))</X><Y>\(number(node.height))</Y><Z>\(number(node.depth))</Z></Vector3>"
                } else if ["Script", "LocalScript", "ModuleScript"].contains(node.className) {
                    let source = node.source.replacingOccurrences(of: "]]>", with: "]]]]><![CDATA[>")
                    xml += "<ProtectedString name=\"Source\"><![CDATA[\(source)]]></ProtectedString>"
                }
                xml += "</Properties></Item>\n"
            }
            xml += "</Item>\n"
        }
        xml += "</roblox>"
        return xml
    }
}

struct StudioViewport: UIViewRepresentable {
    @ObservedObject var project: StudioProject

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = UIColor(red: 0.43, green: 0.62, blue: 0.78, alpha: 1)
        view.isPlaying = false
        view.rendersContinuously = false
        view.preferredFramesPerSecond = 60
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling4X
        view.scene = makeScene()
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.selectNode(_:)))
        view.addGestureRecognizer(tap)
        context.coordinator.view = view
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        context.coordinator.view = view
        view.scene?.rootNode.childNode(withName: "R6CharacterRoot", recursively: false)?.position = SCNVector3(Float(project.playerOffsetX), 0, Float(project.playerOffsetZ))
        if context.coordinator.lastNodes != project.nodes ||
            context.coordinator.lastSelectedID != project.selectedID ||
            view.scene == nil {
            view.scene = makeScene()
            context.coordinator.lastNodes = project.nodes
            context.coordinator.lastSelectedID = project.selectedID
        } else {
            updateCamera(in: view.scene)
        }
    }

    private func updateCamera(in scene: SCNScene?) {
        guard let cameraNode = scene?.rootNode.childNode(withName: "StudioCamera", recursively: false) else { return }
        let hasImportedMesh = project.nodes.contains { $0.className == "MeshPart" }
        let distance: Double = hasImportedMesh ? 15 : 57
        let targetY: Double = hasImportedMesh ? 3.3 : 0
        let horizontal = distance * cos(project.cameraPitch)
        cameraNode.position = SCNVector3(
            Float(project.cameraTargetX + sin(project.cameraYaw) * horizontal),
            Float(targetY + 8 + sin(project.cameraPitch) * distance),
            Float(project.cameraTargetZ + cos(project.cameraYaw) * horizontal)
        )
        cameraNode.look(at: SCNVector3(Float(project.cameraTargetX + (project.isPlaying ? project.playerOffsetX : 0)), Float(targetY), Float(project.cameraTargetZ + (project.isPlaying ? project.playerOffsetZ : 0))))
    }

    func makeCoordinator() -> Coordinator { Coordinator(project: project) }

    final class Coordinator: NSObject {
        let project: StudioProject
        weak var view: SCNView?
        var lastNodes: [StudioNode]?
        var lastSelectedID: UUID?
        init(project: StudioProject) { self.project = project }
        @objc func selectNode(_ gesture: UITapGestureRecognizer) {
            guard let view = view else { return }
            let point = gesture.location(in: view)
            let hit = view.hitTest(point, options: nil).first
            if let idString = hit?.node.name, let id = UUID(uuidString: idString) {
                DispatchQueue.main.async { self.project.selectedID = id }
            }
        }
    }

    private func makeStudTexture() -> UIImage {
        let size = CGSize(width: 128, height: 128)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor(red: 0.39, green: 0.43, blue: 0.50, alpha: 1).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            for row in 0..<8 {
                for column in 0..<8 {
                    let rect = CGRect(x: CGFloat(column) * 16 + 3, y: CGFloat(row) * 16 + 3, width: 10, height: 10)
                    UIColor(red: 0.29, green: 0.33, blue: 0.40, alpha: 1).setFill()
                    UIBezierPath(roundedRect: rect.offsetBy(dx: 1, dy: 1), cornerRadius: 2).fill()
                    UIColor(red: 0.57, green: 0.61, blue: 0.68, alpha: 1).setFill()
                    UIBezierPath(roundedRect: rect, cornerRadius: 2).fill()
                    UIColor.white.withAlphaComponent(0.22).setStroke()
                    let highlight = UIBezierPath(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: 1.5)
                    highlight.lineWidth = 0.7
                    highlight.stroke()
                }
            }
        }
    }

    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor(red: 0.43, green: 0.62, blue: 0.78, alpha: 1)

        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.zNear = 0.1
        camera.zFar = 10000
        camera.fieldOfView = 55
        cameraNode.camera = camera
        cameraNode.name = "StudioCamera"
        let hasImportedMesh = project.nodes.contains { $0.className == "MeshPart" }
        let distance: Double = hasImportedMesh ? 15 : 57
        let targetY: Double = hasImportedMesh ? 3.3 : 0
        let horizontal = distance * cos(project.cameraPitch)
        cameraNode.position = SCNVector3(Float(project.cameraTargetX + sin(project.cameraYaw) * horizontal), Float(targetY + 8 + sin(project.cameraPitch) * distance), Float(project.cameraTargetZ + cos(project.cameraYaw) * horizontal))
        cameraNode.look(at: SCNVector3(Float(project.cameraTargetX), Float(targetY), Float(project.cameraTargetZ)))
        scene.rootNode.addChildNode(cameraNode)

        let ambient = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 650
        ambientLight.color = UIColor(white: 0.85, alpha: 1)
        ambient.light = ambientLight
        scene.rootNode.addChildNode(ambient)

        let sun = SCNNode()
        let sunLight = SCNLight()
        sunLight.type = .directional
        sunLight.intensity = 900
        sunLight.castsShadow = true
        sunLight.shadowMode = .deferred
        sunLight.shadowRadius = 7
        sunLight.shadowColor = UIColor.black.withAlphaComponent(0.42)
        sunLight.shadowMapSize = CGSize(width: 2048, height: 2048)
        sun.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 4, 0)
        sun.light = sunLight
        scene.rootNode.addChildNode(sun)

        let floor = SCNPlane(width: 1200, height: 1200)
        floor.firstMaterial?.diffuse.contents = UIColor(red: 0.34, green: 0.39, blue: 0.48, alpha: 1)
        floor.firstMaterial?.isDoubleSided = true
        let floorNode = SCNNode(geometry: floor)
        floorNode.eulerAngles.x = -.pi / 2
        floorNode.position = SCNVector3(0, -2.15, 0)
        floorNode.castsShadow = false
        scene.rootNode.addChildNode(floorNode)

        for item in project.nodes where item.className == "Part" {
            let geometry: SCNGeometry
            switch item.shape {
            case "Sphere": geometry = SCNSphere(radius: CGFloat(max(item.width, max(item.height, item.depth)) / 2))
            case "Cylinder": geometry = SCNCylinder(radius: CGFloat(item.width / 2), height: CGFloat(item.height))
            case "Wedge": geometry = SCNPyramid(width: CGFloat(item.width), height: CGFloat(item.height), length: CGFloat(item.depth))
            default: geometry = SCNBox(width: CGFloat(item.width), height: CGFloat(item.height), length: CGFloat(item.depth), chamferRadius: 0.04)
            }
            let material = SCNMaterial()
            let partColor: UIColor
            switch item.materialColor {
            case "white": partColor = .white
            case "black", "pants": partColor = UIColor(red: 0.045, green: 0.05, blue: 0.06, alpha: 1)
            case "blue": partColor = UIColor(red: 0.0, green: 0.32, blue: 0.72, alpha: 1)
            case "face": partColor = .black
            case "hairDark": partColor = UIColor(red: 0.24, green: 0.075, blue: 0.018, alpha: 1)
            case "hairLight": partColor = UIColor(red: 0.78, green: 0.30, blue: 0.035, alpha: 1)
            case "hair": partColor = UIColor(red: 0.48, green: 0.16, blue: 0.025, alpha: 1)
            default: partColor = UIColor(red: 0.55, green: 0.62, blue: 0.72, alpha: 1)
            }
            material.diffuse.contents = item.id == project.selectedID ? UIColor.systemBlue : partColor
            material.roughness.contents = 0.82
            material.metalness.contents = 0.02
            material.transparency = 1 - CGFloat(item.transparency)
            if item.name.localizedCaseInsensitiveContains("baseplate") {
                let top = SCNMaterial()
                top.diffuse.contents = makeStudTexture()
                top.diffuse.wrapS = .repeat
                top.diffuse.wrapT = .repeat
                top.diffuse.contentsTransform = SCNMatrix4MakeScale(18, 18, 1)
                top.roughness.contents = 0.92
                let side = SCNMaterial()
                side.diffuse.contents = UIColor(red: 0.39, green: 0.43, blue: 0.50, alpha: 1)
                geometry.materials = [side, side, top, side, side, side]
            } else {
                geometry.materials = [material]
            }
            let node = SCNNode(geometry: geometry)
            node.name = item.id.uuidString
            node.position = SCNVector3(Float(item.x), Float(item.y), Float(item.z))
            node.castsShadow = true
            if item.name.hasPrefix("R6_") {
                var root = scene.rootNode.childNode(withName: "R6CharacterRoot", recursively: false)
                if root == nil { root = SCNNode(); root?.name = "R6CharacterRoot"; scene.rootNode.addChildNode(root!) }
                root?.addChildNode(node)
            } else {
                scene.rootNode.addChildNode(node)
            }
        }
        // Imported OBJ sections are rendered as independent selectable mesh instances.
        for item in project.nodes where item.className == "MeshPart" && !item.meshOBJ.isEmpty {
            let lines = item.meshOBJ.split(whereSeparator: \.isNewline)
            var vertices: [SCNVector3] = []
            var faces: [[Int]] = []
            for line in lines {
                let fields = line.split(whereSeparator: \.isWhitespace)
                guard let kind = fields.first else { continue }
                if kind == "v", fields.count >= 4,
                   let x = Float(fields[1]), let y = Float(fields[2]), let z = Float(fields[3]) {
                    // Center and scale the source character into the editor's Roblox-sized viewport.
                    vertices.append(SCNVector3((x + 20) * 0.12, y * 0.12, (z - 75) * 0.12))
                } else if kind == "f", fields.count >= 4 {
                    let indices = fields.dropFirst().compactMap { token -> Int? in
                        guard let first = token.split(separator: "/").first, let raw = Int(first) else { return nil }
                        return raw > 0 ? raw - 1 : vertices.count + raw
                    }
                    if indices.count >= 3 { faces.append(indices) }
                }
            }
            var positions: [SCNVector3] = []
            var normals: [SCNVector3] = []
            var uvs: [CGPoint] = []
            var triangleIndices: [Int32] = []
            for face in faces {
                guard face.allSatisfy({ vertices.indices.contains($0) }) else { continue }
                for corner in 1..<(face.count - 1) {
                    let tri = [face[0], face[corner], face[corner + 1]]
                    let a = vertices[tri[0]], b = vertices[tri[1]], c = vertices[tri[2]]
                    let ab = SCNVector3(b.x-a.x, b.y-a.y, b.z-a.z)
                    let ac = SCNVector3(c.x-a.x, c.y-a.y, c.z-a.z)
                    var normal = SCNVector3(ab.y*ac.z-ab.z*ac.y, ab.z*ac.x-ab.x*ac.z, ab.x*ac.y-ab.y*ac.x)
                    let length = max(0.0001, sqrt(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z))
                    normal = SCNVector3(normal.x/length, normal.y/length, normal.z/length)
                    for index in tri {
                        let vertex = vertices[index]
                        positions.append(vertex)
                        normals.append(normal)
                        // Front projection matches the supplied full-character atlas.
                        let sourceX = vertex.x / 0.12 - 20
                        let sourceY = vertex.y / 0.12
                        let u: CGFloat = CGFloat(min(1.0, max(0.0, (sourceX + 36.0) / 42.0)))
                        let v: CGFloat = CGFloat(min(1.0, max(0.0, 1.0 - sourceY / 56.0)))
                        uvs.append(CGPoint(x: u, y: v))
                        triangleIndices.append(Int32(triangleIndices.count))
                    }
                }
            }
            guard !positions.isEmpty else { continue }
            let vertexSource = SCNGeometrySource(vertices: positions)
            let normalSource = SCNGeometrySource(normals: normals)
            let uvSource = SCNGeometrySource(textureCoordinates: uvs)
            let element = SCNGeometryElement(indices: triangleIndices, primitiveType: .triangles)
            let geometry = SCNGeometry(sources: [vertexSource, normalSource, uvSource], elements: [element])
            let material = SCNMaterial()
            material.diffuse.contents = item.meshTextureData.flatMap { UIImage(data: $0) } ?? UIColor(red: 0.55, green: 0.28, blue: 0.08, alpha: 1)
            material.diffuse.wrapS = .clamp
            material.diffuse.wrapT = .clamp
            material.lightingModel = .physicallyBased
            material.roughness.contents = 0.72
            material.isDoubleSided = true
            geometry.materials = [material]
            let meshNode = SCNNode(geometry: geometry)
            meshNode.name = item.id.uuidString
            scene.rootNode.addChildNode(meshNode)
        }
        return scene
    }
}
