import Foundation
import SwiftUI
import SceneKit
import UIKit

struct StudioNode: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var className: String
    var x: Double = 0
    var y: Double = 3
    var z: Double = 0
    var width: Double = 4
    var height: Double = 1
    var depth: Double = 4
    var anchored: Bool = true
    var source: String = ""
    var service: String = "Workspace"
}

final class StudioProject: ObservableObject {
    @Published var name: String
    @Published var nodes: [StudioNode] = []
    @Published var selectedID: UUID?
    @Published var activeTab = "Home"

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

    func addPart() {
        let n = StudioNode(name: "Part", className: "Part", x: Double(nodes.count * 3), y: 4)
        nodes.append(n)
        selectedID = n.id
    }

    func addScript() {
        let n = StudioNode(name: "Script", className: "Script", source: "-- Your Roblox Lua code goes here\nprint(\"Hello from RobloxStudioMobile!\")", service: "ServerScriptService")
        nodes.append(n)
        selectedID = n.id
    }

    func updateSelected(_ change: (inout StudioNode) -> Void) {
        guard let id = selectedID, let index = nodes.firstIndex(where: { $0.id == id }) else { return }
        change(&nodes[index])
    }

    func exportXML() -> String {
        func esc(_ s: String) -> String {
            s.replacingOccurrences(of: "&", with: "&amp;")
             .replacingOccurrences(of: "<", with: "&lt;")
             .replacingOccurrences(of: ">", with: "&gt;")
        }
        var xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<roblox version=\"4\">\n<External>null</External>\n<External>null</External>\n"
        let services = ["Workspace", "Players", "Lighting", "ReplicatedStorage", "ServerScriptService", "StarterGui", "StarterPack", "StarterPlayer", "SoundService", "Teams"]
        for (serviceIndex, service) in services.enumerated() {
            let ref = "RBX\(serviceIndex)"
            xml += "<Item class=\"\(service)\" referent=\"\(ref)\"><Properties><string name=\"Name\">\(service)</string></Properties>\n"
            for (index, node) in nodes.filter({ $0.service == service }).enumerated() {
                let nodeRef = "RBXOBJ\(serviceIndex)_\(index)"
                xml += "<Item class=\"\(esc(node.className))\" referent=\"\(nodeRef)\"><Properties><string name=\"Name\">\(esc(node.name))</string>"
                if node.className == "Part" {
                    xml += "<bool name=\"Anchored\">\(node.anchored ? "true" : "false")</bool>"
                    xml += "<CoordinateFrame name=\"CFrame\"><X>\(node.x)</X><Y>\(node.y)</Y><Z>\(node.z)</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame>"
                    xml += "<Vector3 name=\"size\"><X>\(node.width)</X><Y>\(node.height)</Y><Z>\(node.depth)</Z></Vector3>"
                } else if node.className == "Script" || node.className == "LocalScript" {
                    xml += "<ProtectedString name=\"Source\"><![CDATA[\(node.source.replacingOccurrences(of: "]]>", with: "]]]]><![CDATA[>"))]]></ProtectedString>"
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
        view.backgroundColor = UIColor(red: 0.30, green: 0.36, blue: 0.45, alpha: 1)
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.scene = makeScene()
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        view.scene = makeScene()
    }

    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(30, 28, 34)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)

        let floor = SCNFloor()
        floor.reflectivity = 0
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -2.1, 0)
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0.34, green: 0.39, blue: 0.48, alpha: 1)
        scene.rootNode.addChildNode(floorNode)

        for item in project.nodes where item.className == "Part" {
            let box = SCNBox(width: CGFloat(item.width), height: CGFloat(item.height), length: CGFloat(item.depth), chamferRadius: 0.04)
            box.firstMaterial?.diffuse.contents = item.id == project.selectedID ? UIColor.systemBlue : UIColor(red: 0.55, green: 0.62, blue: 0.72, alpha: 1)
            let node = SCNNode(geometry: box)
            node.position = SCNVector3(Float(item.x), Float(item.y), Float(item.z))
            scene.rootNode.addChildNode(node)
        }
        return scene
    }
}
