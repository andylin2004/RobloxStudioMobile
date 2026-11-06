import SwiftUI
import UniformTypeIdentifiers

struct RBXLXExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.rbxlx] }
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

extension UTType {
    static var rbxlx: UTType {
        UTType(filenameExtension: "rbxlx", conformingTo: .xml) ?? .xml
    }
}
