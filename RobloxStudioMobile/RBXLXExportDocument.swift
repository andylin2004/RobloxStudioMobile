import SwiftUI
import UniformTypeIdentifiers

/// FileDocument wrapper for Roblox's XML place format (.rbxlx).
/// The UTType.rbxlx identifier is declared in RobloxStudioMobileApp.swift.
struct RBXLXExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.rbxlx] }
    static var writableContentTypes: [UTType] { [.rbxlx] }

    let xml: String

    init(xml: String) {
        self.xml = xml
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let value = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        xml = value
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = xml.data(using: .utf8) else {
            throw CocoaError(.fileWriteInapplicableStringEncoding)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
