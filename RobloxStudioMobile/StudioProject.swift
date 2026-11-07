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
    @Published var cameraDistance: Double = 57
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

    func zoomViewport(_ amount: Double) {
        cameraDistance = min(240, max(5, cameraDistance + amount))
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


    static func importRBXL(_ data: Data, name: String) throws -> StudioProject {
        let nodes = try RobloxBinaryPlaceImporter.decode(data)
        guard !nodes.isEmpty else { throw NSError(domain: "RobloxStudioMobile.Import", code: 20, userInfo: [NSLocalizedDescriptionKey: "No supported parts were found in this binary place."]) }
        let project = StudioProject(name: name, template: "Baseplate")
        project.nodes = nodes
        project.selectedID = nodes.first?.id
        return project
    }

    static func importRBXLX(_ data: Data, name: String) throws -> StudioProject {
        let parser = XMLParser(data: data)
        let delegate = StudioXMLImportDelegate()
        parser.delegate = delegate
        guard parser.parse(), !delegate.nodes.isEmpty else {
            throw NSError(domain: "RobloxStudioMobile.Import", code: 1, userInfo: [NSLocalizedDescriptionKey: parser.parserError?.localizedDescription ?? "No supported Part instances were found."])
        }
        let project = StudioProject(name: name, template: "Baseplate")
        project.nodes = delegate.nodes
        project.selectedID = project.nodes.first?.id
        return project
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
        let distance: Double = project.cameraDistance
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
            default:
                if item.materialColor.hasPrefix("hex:"), let rgb = Int(item.materialColor.dropFirst(4), radix: 16) {
                    partColor = UIColor(red: CGFloat((rgb >> 16) & 255) / 255, green: CGFloat((rgb >> 8) & 255) / 255, blue: CGFloat(rgb & 255) / 255, alpha: 1)
                } else {
                    partColor = UIColor(red: 0.55, green: 0.62, blue: 0.72, alpha: 1)
                }
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


private final class StudioXMLImportDelegate: NSObject, XMLParserDelegate {
    var nodes: [StudioNode] = []
    private var current: StudioNode?
    private var property = ""
    private var field = ""
    private var text = ""

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "Item" {
            let cls = attributeDict["class"] ?? ""
            if ["Part", "Script", "LocalScript", "ModuleScript"].contains(cls) {
                current = StudioNode(name: cls == "Part" ? "Part" : cls, className: cls)
            }
        } else if ["string", "bool", "float", "token", "CoordinateFrame", "Vector3", "ProtectedString"].contains(elementName) {
            property = attributeDict["name"] ?? elementName
            field = ""
            text = ""
        } else if ["X", "Y", "Z"].contains(elementName) {
            field = elementName
            text = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) { text += string }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let value = String(data: CDATABlock, encoding: .utf8) { text += value }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard current != nil else { return }
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if ["Name", "Source", "Anchored", "CanCollide", "Transparency", "Shape"].contains(property), ["string", "bool", "float", "token", "ProtectedString"].contains(elementName) {
            switch property {
            case "Name": current?.name = value
            case "Source": current?.source = value
            case "Anchored": current?.anchored = value == "true"
            case "CanCollide": current?.canCollide = value == "true"
            case "Transparency": current?.transparency = Double(value) ?? 0
            case "Shape":
                let token = Int(value) ?? 1
                current?.shape = token == 0 ? "Sphere" : (token == 2 ? "Cylinder" : "Block")
            default: break
            }
            property = ""
        } else if ["X", "Y", "Z"].contains(elementName), let number = Double(value) {
            if property == "CFrame" {
                if field == "X" { current?.x = number }
                if field == "Y" { current?.y = number }
                if field == "Z" { current?.z = number }
            } else if property == "size" {
                if field == "X" { current?.width = number }
                if field == "Y" { current?.height = number }
                if field == "Z" { current?.depth = number }
            }
            field = ""
        } else if elementName == "Item", let item = current {
            nodes.append(item)
            current = nil
            property = ""
        }
        if ["X", "Y", "Z"].contains(elementName) { text = "" }
    }
}


// Defensive version-0 RBXL reader. It decodes instance tables, parent links and common Part properties.
// Unknown PROP chunks are skipped safely because each property is stored in its own framed chunk.
private enum RobloxBinaryPlaceImporter {
    private struct Reader {
        let b: [UInt8]
        var p = 0
        var left: Int { b.count - p }
        mutating func take(_ n: Int) throws -> [UInt8] {
            guard n >= 0, n <= left else { throw err("Truncated binary place file.") }
            let v = Array(b[p..<(p+n)]); p += n; return v
        }
        mutating func byte() throws -> UInt8 { try take(1)[0] }
        mutating func u16() throws -> UInt16 { let v = try take(2); return UInt16(v[0]) | UInt16(v[1]) << 8 }
        mutating func u32() throws -> UInt32 {
            let v = try take(4)
            return UInt32(v[0]) | UInt32(v[1]) << 8 | UInt32(v[2]) << 16 | UInt32(v[3]) << 24
        }
        mutating func i32() throws -> Int32 { Int32(bitPattern: try u32()) }
        mutating func string() throws -> String {
            let n = Int(try u32())
            guard n <= 16_777_216 else { throw err("Invalid string length in binary place.") }
            return String(decoding: try take(n), as: UTF8.self)
        }
        func err(_ s: String) -> NSError {
            NSError(domain: "RobloxStudioMobile.RBXL", code: 50, userInfo: [NSLocalizedDescriptionKey: s])
        }
    }
    private struct Item {
        var node: StudioNode
        var service: Bool
    }

    static func decode(_ data: Data) throws -> [StudioNode] {
        let bytes = [UInt8](data)
        let sig: [UInt8] = [60,114,111,98,108,111,120,33,137,255,13,10,26,10]
        guard bytes.count >= 32, Array(bytes.prefix(14)) == sig else {
            throw NSError(domain: "RobloxStudioMobile.RBXL", code: 51, userInfo: [NSLocalizedDescriptionKey: "Invalid binary .rbxl signature."])
        }
        guard bytes.count <= 100 * 1024 * 1024 else {
            throw NSError(domain: "RobloxStudioMobile.RBXL", code: 52, userInfo: [NSLocalizedDescriptionKey: "This file exceeds the current 100 MB import limit."])
        }
        var h = Reader(b: bytes, p: 14)
        let version = try h.u16()
        let classCount = try h.u32()
        let totalCount = try h.u32()
        _ = try h.take(8)
        guard version == 0 else { throw h.err("Unsupported RBXL binary version.") }
        guard classCount <= 100_000, totalCount <= 1_000_000 else { throw h.err("The place declares too many objects to load safely.") }

        var groups: [Int32: [Int32]] = [:]
        var classes: [Int32: String] = [:]
        var objects: [Int32: Item] = [:]
        var parents: [Int32: Int32] = [:]
        var pos = 32
        var ended = false

        while pos + 16 <= bytes.count {
            let tag = String(decoding: bytes[pos..<(pos+4)], as: UTF8.self)
            func readLE(_ at: Int) -> Int {
                Int(UInt32(bytes[at]) | UInt32(bytes[at+1]) << 8 | UInt32(bytes[at+2]) << 16 | UInt32(bytes[at+3]) << 24)
            }
            let packed = readLE(pos+4), expanded = readLE(pos+8)
            pos += 16
            let stored = packed == 0 ? expanded : packed
            guard stored >= 0, expanded >= 0, stored <= bytes.count-pos, expanded <= 128*1024*1024 else { throw h.err("Invalid binary chunk length.") }
            let raw = Array(bytes[pos..<(pos+stored)]); pos += stored
            let payload: [UInt8]
            if packed == 0 { payload = raw }
            else {
                if raw.count >= 4 && raw[0] == 0x28 && raw[1] == 0xb5 && raw[2] == 0x2f && raw[3] == 0xfd {
                    throw h.err("This place uses Zstandard compression. The current importer supports legacy LZ4 chunks, not Zstandard yet.")
                }
                payload = try lz4(raw, size: expanded)
            }

            switch tag {
            case "INST":
                var r = Reader(b: payload)
                let id = try r.i32()
                let cls = try r.string()
                let hasFlags = try r.byte() != 0
                let count = Int(try r.u32())
                guard count <= 1_000_000 else { throw r.err("Instance group is too large.") }
                let refs = try references(&r, count)
                var flags = [Bool](repeating: false, count: count)
                if hasFlags { for i in 0..<count { flags[i] = try r.byte() != 0 } }
                groups[id] = refs; classes[id] = cls
                for i in refs.indices {
                    var node = StudioNode(name: cls, className: cls)
                    if cls == "WedgePart" || cls == "CornerWedgePart" { node.shape = "Wedge" }
                    if cls == "Ball" { node.shape = "Sphere" }
                    if cls == "Cylinder" { node.shape = "Cylinder" }
                    objects[refs[i]] = Item(node: node, service: flags[i])
                }
            case "PROP":
                var r = Reader(b: payload)
                let id = try r.i32()
                let prop = try r.string()
                let type = try r.byte()
                guard let refs = groups[id], let cls = classes[id] else { continue }
                let basePart = ["Part","WedgePart","CornerWedgePart","TrussPart","SpawnLocation","Seat","VehicleSeat","MeshPart","UnionOperation"].contains(cls)
                let wanted = prop == "Name" ||
                    (basePart && ["CFrame","Size","Anchored","CanCollide","Transparency","Shape","Color"].contains(prop)) ||
                    (["Script","LocalScript","ModuleScript"].contains(cls) && prop == "Source")
                guard wanted else { continue }
                switch type {
                case 1:
                    for ref in refs {
                        let value = try r.string()
                        if var item = objects[ref] {
                            if prop == "Name" { item.node.name = value }
                            if prop == "Source" { item.node.source = value }
                            objects[ref] = item
                        }
                    }
                case 2:
                    for ref in refs {
                        let value = try r.byte() != 0
                        if var item = objects[ref] {
                            if prop == "Anchored" { item.node.anchored = value }
                            if prop == "CanCollide" { item.node.canCollide = value }
                            objects[ref] = item
                        }
                    }
                case 4:
                    let v = try floats(&r, refs.count)
                    for (i, ref) in refs.enumerated() {
                        if var item = objects[ref] {
                            if prop == "Transparency" { item.node.transparency = Double(min(1, max(0, v[i]))) }
                            objects[ref] = item
                        }
                    }
                case 12:
                    let red = try floats(&r, refs.count), green = try floats(&r, refs.count), blue = try floats(&r, refs.count)
                    for (i, ref) in refs.enumerated() {
                        if var item = objects[ref] {
                            if prop == "Color" { item.node.materialColor = String(format: "hex:%02X%02X%02X", Int(min(255, max(0, red[i] * 255))), Int(min(255, max(0, green[i] * 255))), Int(min(255, max(0, blue[i] * 255)))) }
                            objects[ref] = item
                        }
                    }
                case 14:
                    let x = try floats(&r, refs.count), y = try floats(&r, refs.count), z = try floats(&r, refs.count)
                    for (i, ref) in refs.enumerated() {
                        if var item = objects[ref] {
                            if prop == "Size" {
                                item.node.width = max(0.05, Double(x[i]))
                                item.node.height = max(0.05, Double(y[i]))
                                item.node.depth = max(0.05, Double(z[i]))
                            }
                            objects[ref] = item
                        }
                    }
                case 16:
                    for _ in refs { if try r.byte() == 0 { _ = try r.take(36) } }
                    let x = try floats(&r, refs.count), y = try floats(&r, refs.count), z = try floats(&r, refs.count)
                    for (i, ref) in refs.enumerated() {
                        if var item = objects[ref] {
                            if prop == "CFrame" { item.node.x = Double(x[i]); item.node.y = Double(y[i]); item.node.z = Double(z[i]) }
                            objects[ref] = item
                        }
                    }
                case 18:
                    let tokens = try interleaved(&r, refs.count)
                    for (i, ref) in refs.enumerated() {
                        if var item = objects[ref] {
                            if prop == "Shape" {
                                item.node.shape = tokens[i] == 0 ? "Sphere" : (tokens[i] == 2 ? "Cylinder" : ((tokens[i] == 3 || tokens[i] == 4) ? "Wedge" : "Block"))
                            }
                            objects[ref] = item
                        }
                    }
                default:
                    break
                }
            case "PRNT":
                var r = Reader(b: payload)
                _ = try r.byte()
                let count = Int(try r.u32())
                guard count <= 1_000_000 else { throw r.err("Parent table is too large.") }
                let children = try references(&r, count), owners = try references(&r, count)
                for i in 0..<min(children.count, owners.count) { parents[children[i]] = owners[i] }
            case "END.", "END\u{0}":
                ended = true
            default:
                break
            }
            if ended { break }
        }
        guard ended else { throw h.err("The binary place is incomplete; its END chunk is missing.") }

        func serviceOf(_ start: Int32) -> String {
            var current = start
            var seen = Set<Int32>()
            while seen.insert(current).inserted, let item = objects[current] {
                if item.service { return item.node.name }
                guard let parent = parents[current], parent >= 0 else { break }
                current = parent
            }
            return "Workspace"
        }
        return objects.keys.sorted().compactMap { ref in
            guard var item = objects[ref] else { return nil }
            let cls = item.node.className
            if ["Part","WedgePart","CornerWedgePart","TrussPart","SpawnLocation","Seat","VehicleSeat","MeshPart","UnionOperation"].contains(cls) {
                item.node.className = "Part"
                if cls == "WedgePart" || cls == "CornerWedgePart" { item.node.shape = "Wedge" }
            }
            item.node.service = serviceOf(ref)
            return item.node
        }
    }

    private static func interleaved(_ r: inout Reader, _ n: Int) throws -> [UInt32] {
        guard n >= 0, n <= 1_000_000 else { throw r.err("Invalid array length.") }
        let b = try r.take(n*4)
        return (0..<n).map { i in
            UInt32(b[i]) << 24 | UInt32(b[n+i]) << 16 | UInt32(b[2*n+i]) << 8 | UInt32(b[3*n+i])
        }
    }
    private static func references(_ r: inout Reader, _ n: Int) throws -> [Int32] {
        var previous: Int32 = 0
        return try interleaved(&r, n).map { value in
            let delta = Int32(bitPattern: (value >> 1) ^ (0 &- (value & 1)))
            previous = previous &+ delta
            return previous
        }
    }
    private static func floats(_ r: inout Reader, _ n: Int) throws -> [Float] {
        try interleaved(&r, n).map { value in
            Float(bitPattern: (value >> 1) | ((value & 1) << 31))
        }
    }
    private static func lz4(_ input: [UInt8], size: Int) throws -> [UInt8] {
        var out = [UInt8](); out.reserveCapacity(size)
        var i = 0
        func length(_ base: Int, _ bytes: [UInt8], _ cursor: inout Int) throws -> Int {
            var result = base
            if base == 15 {
                while true {
                    guard cursor < bytes.count else { throw NSError(domain: "RobloxStudioMobile.RBXL", code: 60, userInfo: [NSLocalizedDescriptionKey: "Invalid LZ4 length."]) }
                    let next = Int(bytes[cursor]); cursor += 1; result += next
                    if next != 255 { break }
                }
            }
            return result
        }
        while i < input.count {
            let token = input[i]; i += 1
            let literals = try length(Int(token >> 4), input, &i)
            guard literals <= input.count-i, out.count+literals <= size else { throw NSError(domain: "RobloxStudioMobile.RBXL", code: 61, userInfo: [NSLocalizedDescriptionKey: "Invalid LZ4 literal run."]) }
            out.append(contentsOf: input[i..<(i+literals)]); i += literals
            if i == input.count { break }
            guard i+2 <= input.count else { throw NSError(domain: "RobloxStudioMobile.RBXL", code: 62, userInfo: [NSLocalizedDescriptionKey: "Truncated LZ4 match."]) }
            let distance = Int(input[i]) | Int(input[i+1]) << 8; i += 2
            guard distance > 0, distance <= out.count else { throw NSError(domain: "RobloxStudioMobile.RBXL", code: 63, userInfo: [NSLocalizedDescriptionKey: "Invalid LZ4 back-reference."]) }
            let count = try length(Int(token & 15), input, &i) + 4
            guard out.count+count <= size else { throw NSError(domain: "RobloxStudioMobile.RBXL", code: 64, userInfo: [NSLocalizedDescriptionKey: "LZ4 chunk expands beyond its declared size."]) }
            for _ in 0..<count { out.append(out[out.count-distance]) }
        }
        guard out.count == size else { throw NSError(domain: "RobloxStudioMobile.RBXL", code: 65, userInfo: [NSLocalizedDescriptionKey: "LZ4 chunk size does not match its header."]) }
        return out
    }
}

