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
    var isAvatarAsset: Bool = false
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
    @Published var isMoving = false
    @Published var jumpCount = 0

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
    }


    func togglePlay() {
        isPlaying.toggle()
        if !isPlaying {
            isMoving = false
            playerOffsetX = 0
            playerOffsetZ = 0
        }
    }

    func jumpPlayer() { if isPlaying { jumpCount += 1 } }

    func movePlayer(_ x: Double, _ z: Double) {
        guard isPlaying else { return }
        isMoving = abs(x) + abs(z) > 0.001
        playerOffsetX += x
        playerOffsetZ += z
    }

    func addR6Rig() {
        // This project uses the supplied BaconHair OBJ pieces as the avatar asset.
        // A complete body rig must be supplied separately; do not fabricate replacement body geometry.
        let imported = nodes.filter { $0.isAvatarAsset }
        guard !imported.isEmpty else { return }
        selectedID = imported.first?.id
    }

    func insertToolboxItem(_ item: String) {
        switch item {
        case "Block": addPart(shape: "Block")
        case "Sphere": addPart(shape: "Sphere")
        case "Cylinder": addPart(shape: "Cylinder")
        case "Wedge", "Corner Wedge": addPart(shape: "Wedge")
        case "Truss":
            let base = StudioNode(name: "Truss", className: "Part", shape: "Block", x: 0, y: 4, width: 1, height: 6, depth: 1)
            nodes.append(base); selectedID = base.id
        case "Tree":
            let trunk = StudioNode(name: "Tree_Trunk", className: "Part", x: 0, y: 2, width: 0.8, height: 4, depth: 0.8, materialColor: "trunk")
            let crown = StudioNode(name: "Tree_Crown", className: "Part", shape: "Sphere", x: 0, y: 5, width: 4, height: 4, depth: 4, materialColor: "leaf")
            nodes.append(contentsOf: [trunk, crown]); selectedID = crown.id
        case "House":
            let pieces = [
                StudioNode(name: "House_Body", className: "Part", x: 0, y: 3, width: 8, height: 5, depth: 7, materialColor: "wall"),
                StudioNode(name: "House_Roof", className: "Part", shape: "Wedge", x: 0, y: 6.2, width: 9, height: 2, depth: 8, materialColor: "roof"),
                StudioNode(name: "House_Door", className: "Part", x: 0, y: 1.5, z: 3.56, width: 1.5, height: 3, depth: 0.12, materialColor: "door")
            ]
            nodes.append(contentsOf: pieces); selectedID = pieces[0].id
        case "Car":
            let pieces = [
                StudioNode(name: "Car_Body", className: "Part", x: 0, y: 1.2, width: 7, height: 1.5, depth: 3.5, materialColor: "car"),
                StudioNode(name: "Car_Cabin", className: "Part", x: 0, y: 2.4, width: 3.8, height: 1.4, depth: 3, materialColor: "glass"),
                StudioNode(name: "Car_Wheel_FL", className: "Part", shape: "Cylinder", x: -2.2, y: 0.55, z: 1.5, width: 1.2, height: 0.5, depth: 1.2, materialColor: "tire"),
                StudioNode(name: "Car_Wheel_FR", className: "Part", shape: "Cylinder", x: 2.2, y: 0.55, z: 1.5, width: 1.2, height: 0.5, depth: 1.2, materialColor: "tire"),
                StudioNode(name: "Car_Wheel_BL", className: "Part", shape: "Cylinder", x: -2.2, y: 0.55, z: -1.5, width: 1.2, height: 0.5, depth: 1.2, materialColor: "tire"),
                StudioNode(name: "Car_Wheel_BR", className: "Part", shape: "Cylinder", x: 2.2, y: 0.55, z: -1.5, width: 1.2, height: 0.5, depth: 1.2, materialColor: "tire")
            ]
            nodes.append(contentsOf: pieces); selectedID = pieces[0].id
        case "R6 Rig", "R15 Rig", "NPC": addR6Rig()
        default: addPart()
        }
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
        view.isPlaying = project.isPlaying
        view.rendersContinuously = project.isPlaying
        view.allowsCameraControl = !project.isPlaying
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
        for item in project.nodes where item.isAvatarAsset {
            view.scene?.rootNode.childNode(withName: item.id.uuidString, recursively: true)?.isHidden = !project.isPlaying
        }
        updateCharacterAnimation(in: view.scene, coordinator: context.coordinator)
        if context.coordinator.lastJumpCount != project.jumpCount {
            context.coordinator.lastJumpCount = project.jumpCount
            if let root = view.scene?.rootNode.childNode(withName: "R6CharacterRoot", recursively: false) {
                let up = SCNAction.moveBy(x: 0, y: 1.8, z: 0, duration: 0.22)
                let down = SCNAction.moveBy(x: 0, y: -1.8, z: 0, duration: 0.26)
                up.timingMode = .easeOut
                down.timingMode = .easeIn
                root.runAction(SCNAction.sequence([up, down]), forKey: "R6Jump")
            }
        }
    }

    private func updateCharacterAnimation(in scene: SCNScene?, coordinator: Coordinator) {
        guard coordinator.lastIsPlaying != project.isPlaying || coordinator.lastIsMoving != project.isMoving else { return }
        coordinator.lastIsPlaying = project.isPlaying
        coordinator.lastIsMoving = project.isMoving
        for partName in ["R6_LeftArm", "R6_RightArm", "R6_LeftLeg", "R6_RightLeg"] {
            guard let item = project.nodes.first(where: { $0.name == partName }),
                  let node = scene?.rootNode.childNode(withName: item.id.uuidString, recursively: true) else { continue }
            node.removeAllActions()
            guard project.isPlaying else { node.eulerAngles.x = 0; continue }
            let moving = project.isMoving
            let isLeft = partName.contains("Left")
            let isLeg = partName.contains("Leg")
            let direction: CGFloat = (isLeft == isLeg) ? 1 : -1
            let swing: CGFloat = moving ? 0.48 : 0.035
            let first = SCNAction.rotateTo(x: swing * direction, y: 0, z: 0, duration: moving ? 0.24 : 1.1, usesShortestUnitArc: true)
            let second = SCNAction.rotateTo(x: -swing * direction, y: 0, z: 0, duration: moving ? 0.24 : 1.1, usesShortestUnitArc: true)
            first.timingMode = .easeInEaseOut
            second.timingMode = .easeInEaseOut
            node.runAction(SCNAction.repeatForever(SCNAction.sequence([first, second])), forKey: "R6Walk")
        }
    }
    private func updateCamera(in scene: SCNScene?) {
        guard let cameraNode = scene?.rootNode.childNode(withName: "StudioCamera", recursively: false) else { return }
        let hasCharacter = project.nodes.contains { $0.isAvatarAsset }
        let distance: Double = hasCharacter ? 16 : 57
        let targetY: Double = hasCharacter ? 3.2 : 0
        let horizontal = distance * cos(project.cameraPitch)
        if project.isPlaying {
            cameraNode.position = SCNVector3(Float(project.playerOffsetX), 4.9, Float(project.playerOffsetZ))
            cameraNode.camera?.fieldOfView = 78
            cameraNode.look(at: SCNVector3(Float(project.playerOffsetX), 4.9, Float(project.playerOffsetZ + 10)))
        } else {
            cameraNode.camera?.fieldOfView = 55
            cameraNode.position = SCNVector3(Float(project.cameraTargetX + sin(project.cameraYaw) * horizontal), Float(targetY + 8 + sin(project.cameraPitch) * distance), Float(project.cameraTargetZ + cos(project.cameraYaw) * horizontal))
            cameraNode.look(at: SCNVector3(Float(project.cameraTargetX), Float(targetY), Float(project.cameraTargetZ)))
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(project: project) }

    final class Coordinator: NSObject {
        let project: StudioProject
        weak var view: SCNView?
        var lastNodes: [StudioNode]?
        var lastSelectedID: UUID?
        var lastIsPlaying = false
        var lastIsMoving = false
        var lastJumpCount = 0
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
        let hasCharacter = project.nodes.contains { $0.isAvatarAsset }
        let distance: Double = hasCharacter ? 16 : 57
        let targetY: Double = hasCharacter ? 3.2 : 0
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
            default: geometry = SCNBox(width: CGFloat(item.width), height: CGFloat(item.height), length: CGFloat(item.depth), chamferRadius: item.name.contains("Hair") ? 0.16 : 0.04)
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
            case "trunk": partColor = UIColor.brown
            case "leaf": partColor = .systemGreen
            case "wall": partColor = UIColor(red: 0.78, green: 0.65, blue: 0.48, alpha: 1)
            case "roof": partColor = .systemRed
            case "door": partColor = UIColor.brown
            case "car": partColor = .systemRed
            case "glass": partColor = UIColor.cyan.withAlphaComponent(0.7)
            case "tire": partColor = .darkGray
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
            meshNode.isHidden = item.isAvatarAsset && !project.isPlaying
            scene.rootNode.addChildNode(meshNode)
        }
        updateCamera(in: scene)
        return scene
    }
}
