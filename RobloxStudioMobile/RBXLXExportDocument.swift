import SwiftUI
import UniformTypeIdentifiers

struct RBXLXExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [UTType("com.andylin.robloxstudiomobile.RobloxGameFile") ?? .xml] }
    var text: String

    init(text: String) { self.text = text }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let value = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = value
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = text.data(using: .utf8) else {
            throw CocoaError(.fileWriteInapplicableStringEncoding)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}


struct RBXLBinaryExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [UTType(filenameExtension: "rbxl") ?? .data] }
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws {
        guard let contents = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }
        data = contents
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

extension StudioProject {
    func exportBinaryRBXL() throws -> Data {
        struct InstanceRecord {
            let className: String
            let name: String
            let node: StudioNode?
            let isService: Bool
            var parentID: Int32
        }

        var records: [InstanceRecord] = []
        let serviceNames = services
        for service in serviceNames {
            records.append(InstanceRecord(className: service, name: service, node: nil, isService: true, parentID: -1))
        }
        let serviceIndex = Dictionary(uniqueKeysWithValues: serviceNames.enumerated().map { ($1, Int32($0)) })
        for node in nodes {
            guard let parent = serviceIndex[node.service] else { continue }
            records.append(InstanceRecord(className: node.className, name: node.name, node: node, isService: false, parentID: parent))
        }

        let grouped = Dictionary(grouping: Array(records.enumerated()), by: { $0.element.className })
        let classNames = grouped.keys.sorted()
        var ordered: [InstanceRecord] = []
        var classIDs: [String: Int32] = [:]
        for (classID, className) in classNames.enumerated() {
            classIDs[className] = Int32(classID)
            ordered.append(contentsOf: (grouped[className] ?? []).map { $0.element })
        }
        // Build stable IDs from object identity and service names.
        var recordIDs: [String: Int32] = [:]
        for (index, record) in ordered.enumerated() {
            let key = record.node?.id.uuidString ?? "service:" + record.name
            recordIDs[key] = Int32(index)
        }
        let serviceIDs = Dictionary(uniqueKeysWithValues: serviceNames.compactMap { name in
            recordIDs["service:" + name].map { (name, $0) }
        })

        func putU8(_ value: UInt8, into data: inout Data) { data.append(value) }
        func putU16(_ value: UInt16, into data: inout Data) {
            data.append(UInt8(value & 0xff)); data.append(UInt8((value >> 8) & 0xff))
        }
        func putI32(_ value: Int32, into data: inout Data) {
            let bits = UInt32(bitPattern: value)
            for shift in stride(from: 0, through: 24, by: 8) { data.append(UInt8((bits >> UInt32(shift)) & 0xff)) }
        }
        func putU32(_ value: UInt32, into data: inout Data) {
            for shift in stride(from: 0, through: 24, by: 8) { data.append(UInt8((value >> UInt32(shift)) & 0xff)) }
        }
        func putString(_ value: String, into data: inout Data) {
            let bytes = Data(value.utf8)
            putU32(UInt32(bytes.count), into: &data)
            data.append(bytes)
        }
        func zigzag(_ value: Int32) -> UInt32 { (UInt32(bitPattern: value) << 1) ^ UInt32(bitPattern: value >> 31) }
        func interleave(_ values: [[UInt8]]) -> [UInt8] {
            guard let width = values.first?.count else { return [] }
            var output: [UInt8] = []
            for byte in 0..<width { for value in values { output.append(value[byte]) } }
            return output
        }
        func refBytes(_ values: [Int32]) -> [UInt8] {
            var previous: Int32 = 0
            let encoded = values.map { value -> [UInt8] in
                let delta = value &- previous
                previous = value
                let v = zigzag(delta)
                return [UInt8((v >> 24) & 255), UInt8((v >> 16) & 255), UInt8((v >> 8) & 255), UInt8(v & 255)]
            }
            return interleave(encoded)
        }
        func rotatedFloat(_ value: Float) -> [UInt8] {
            let bits = value.bitPattern
            let rotated = (bits << 1) | (bits >> 31)
            return [UInt8((rotated >> 24) & 255), UInt8((rotated >> 16) & 255), UInt8((rotated >> 8) & 255), UInt8(rotated & 255)]
        }
        func floatArray(_ values: [Float]) -> [UInt8] {
            interleave(values.map { rotatedFloat($0) })
        }
        func vector3Array(_ values: [[Float]]) -> [UInt8] {
            interleave(values.map { vector in vector.flatMap { rotatedFloat($0) } })
        }
        func appendChunk(_ signature: String, payload: Data, to output: inout Data) {
            output.append(Data(signature.utf8.prefix(4)))
            putU32(0, into: &output)
            putU32(UInt32(payload.count), into: &output)
            output.append(contentsOf: [0, 0, 0, 0])
            output.append(payload)
        }

        var output = Data([0x3c,0x72,0x6f,0x62,0x6c,0x6f,0x78,0x21,0x89,0xff,0x0d,0x0a,0x1a,0x0a])
        putU16(0, into: &output)
        putU32(UInt32(classNames.count), into: &output)
        putU32(UInt32(ordered.count), into: &output)
        output.append(contentsOf: [0,0,0,0,0,0,0,0])

        for className in classNames {
            let entries = (grouped[className] ?? []).map { $0.element }
            let classID = classIDs[className] ?? 0
            var payload = Data()
            putI32(classID, into: &payload)
            putString(className, into: &payload)
            let hasService = entries.contains { $0.isService }
            putU8(hasService ? 1 : 0, into: &payload)
            putU32(UInt32(entries.count), into: &payload)
            let ids = entries.map { entry -> Int32 in
                let key = entry.node?.id.uuidString ?? "service:" + entry.name
                return recordIDs[key] ?? 0
            }
            payload.append(contentsOf: refBytes(ids))
            if hasService { payload.append(contentsOf: entries.map { $0.isService ? UInt8(1) : UInt8(0) }) }
            appendChunk("INST", payload: payload, to: &output)

            func property(_ name: String, type: UInt8, bytes: [UInt8]) {
                var p = Data()
                putI32(classID, into: &p)
                putString(name, into: &p)
                putU8(type, into: &p)
                p.append(contentsOf: bytes)
                appendChunk("PROP", payload: p, to: &output)
            }
            property("Name", type: 0x01, bytes: entries.flatMap { entry -> [UInt8] in
                var d = Data(); putString(entry.name, into: &d); return Array(d)
            })
            if className == "Part" {
                let parts = entries.compactMap { $0.node }
                property("Anchored", type: 0x02, bytes: parts.map { $0.anchored ? UInt8(1) : UInt8(0) })
                property("CanCollide", type: 0x02, bytes: parts.map { $0.canCollide ? UInt8(1) : UInt8(0) })
                property("Transparency", type: 0x04, bytes: floatArray(parts.map { Float($0.transparency) }))
                var shapeBytes: [[UInt8]] = []
                for part in parts {
                    let token: UInt32 = part.shape == "Sphere" ? 0 : (part.shape == "Cylinder" ? 2 : 1)
                    shapeBytes.append([UInt8((token >> 24) & 255), UInt8((token >> 16) & 255), UInt8((token >> 8) & 255), UInt8(token & 255)])
                }
                property("Shape", type: 0x12, bytes: interleave(shapeBytes))
                var cframe = Data()
                for _ in parts { putU8(0x02, into: &cframe) }
                cframe.append(contentsOf: vector3Array(parts.map { [Float($0.x), Float($0.y), Float($0.z)] }))
                property("CFrame", type: 0x10, bytes: Array(cframe))
                property("Size", type: 0x0E, bytes: vector3Array(parts.map { [Float($0.width), Float($0.height), Float($0.depth)] }))
            } else if ["Script", "LocalScript", "ModuleScript"].contains(className) {
                property("Source", type: 0x01, bytes: entries.flatMap { entry -> [UInt8] in
                    var d = Data(); putString(entry.node?.source ?? "", into: &d); return Array(d)
                })
            }
        }

        var parentPayload = Data()
        putU8(0, into: &parentPayload)
        putU32(UInt32(ordered.count), into: &parentPayload)
        let childIDs = Array(ordered.indices).map { Int32($0) }
        let parentIDs: [Int32] = ordered.map { record in
            if record.isService { return -1 }
            return serviceIDs[record.node!.service] ?? -1
        }
        parentPayload.append(contentsOf: refBytes(childIDs))
        parentPayload.append(contentsOf: refBytes(parentIDs))
        appendChunk("PRNT", payload: parentPayload, to: &output)
        appendChunk("END\0", payload: Data("</roblox>".utf8), to: &output)
        return output
    }
}
