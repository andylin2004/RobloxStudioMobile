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
}

final class StudioProject: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String
    @Published var nodes: [StudioNode] = []
    @Published var selectedID: UUID?
    @Published var activeTab = "Home"

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
                    let shapeToken = node.shape == "Sphere" ? 1 : (node.shape == "Cylinder" ? 2 : 0)
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
        view.isPlaying = true
        view.rendersContinuously = true
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
        view.scene = makeScene()
        context.coordinator.view = view
    }

    func makeCoordinator() -> Coordinator { Coordinator(project: project) }

    final class Coordinator: NSObject {
        let project: StudioProject
        weak var view: SCNView?
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

    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor(red: 0.43, green: 0.62, blue: 0.78, alpha: 1)

        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.zNear = 0.1
        camera.zFar = 10000
        camera.fieldOfView = 55
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(38, 32, 42)
        cameraNode.look(at: SCNVector3(0, 0, 0))
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
        sun.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 4, 0)
        sun.light = sunLight
        scene.rootNode.addChildNode(sun)

        let floor = SCNPlane(width: 1200, height: 1200)
        floor.firstMaterial?.diffuse.contents = UIColor(red: 0.34, green: 0.39, blue: 0.48, alpha: 1)
        floor.firstMaterial?.isDoubleSided = true
        let floorNode = SCNNode(geometry: floor)
        floorNode.eulerAngles.x = -.pi / 2
        floorNode.position = SCNVector3(0, -2.15, 0)
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
            material.diffuse.contents = item.id == project.selectedID ? UIColor.systemBlue : UIColor(red: 0.55, green: 0.62, blue: 0.72, alpha: 1)
            material.transparency = 1 - CGFloat(item.transparency)
            geometry.materials = [material]
            let node = SCNNode(geometry: geometry)
            node.name = item.id.uuidString
            node.position = SCNVector3(Float(item.x), Float(item.y), Float(item.z))
            scene.rootNode.addChildNode(node)
        }
        return scene
    }
}
