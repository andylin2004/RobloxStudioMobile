//
//  RobloxStudioMobileApp.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI
import UniformTypeIdentifiers
import Foundation

@main
struct RobloxStudioMobileApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct InputDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.xml] }
    
    var input: String
    
    init(input: String) {
        self.input = input
    }
    
    init(configuration: FileDocumentReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        input = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: input.data(using: .utf8)!)
    }
    
}

extension UTType {
    //rbxlx
    static var rbxlx: UTType {
        // Look up the type from the file extension
        UTType.types(tag: "rbxlx", tagClass: .filenameExtension, conformingTo: .xml).first!
    }
}

func parseFile(data: String) -> Array<RbxObject>{
    let toParse = data.split(whereSeparator: \.isNewline)
    return parseFile(data: toParse, startAtLine: 3, endAtLine: toParse.count-5)
}

func parseFile(data: Array<Substring>, startAtLine: Int, endAtLine: Int) -> Array<RbxObject>{
    var lineNum = startAtLine
    
    var array: Array<RbxObject> = []
    var mode = 0 //0 = wait for property 1 = at property 2 = at child 3 = find end of child
    
    var tempName = ""
    var lookForNumOfTabs = 0
    var propertyStart = 0
    var propertyEnd = 0
    var tempClassName = ""
    while lineNum <= endAtLine{
        if data[lineNum].replacingOccurrences(of: "\t", with: "").first == "<"{
            let numOfTabs = data[lineNum].components(separatedBy: "\t").count
            var line = data[lineNum].replacingOccurrences(of: "\t", with: "")
            line.removeFirst()
            line.removeLast()
            let parsing = line.split(separator: " ")
            
            switch mode {
            case 0:
                if parsing.first == "Item"{
                    lookForNumOfTabs = numOfTabs
                    tempClassName = String(parsing[1])
                    tempClassName.removeFirst(7)
                    tempClassName.removeLast()
                    tempName = tempClassName
                }else if parsing.first == "Properties" && lookForNumOfTabs + 1 == numOfTabs{
                    propertyStart = lineNum
                    mode = 1
                }
            case 1:
                if parsing.first == "/Properties" && lookForNumOfTabs + 1 == numOfTabs{
                    propertyEnd = lineNum
                    mode = 2
                }else if parsing.count > 1 && parsing.first == "string" && String(parsing[1]).prefix(11) == "name=\"Name\"" && lookForNumOfTabs + 2 == numOfTabs{
                    tempName = String(line[line.index(after: line.firstIndex(of: ">")!)..<line.lastIndex(of: "<")!])
                }
            case 2:
                if parsing.first == "/Item" && lookForNumOfTabs == numOfTabs{
                    array.append(RbxObject(name: tempName, className: tempClassName, propertyStart: propertyStart, propertyEnd: propertyEnd))
                    mode = 0
                }else{
                    mode = 3
                }
            default:
                if parsing.first == "/Item" && lookForNumOfTabs == numOfTabs{
                    array.append(RbxObject(name: tempName, className: tempClassName, propertyStart: propertyStart, propertyEnd: propertyEnd, childStart: propertyEnd+1, childEnd: lineNum-1))
                    mode = 0
                }
            }
        }
        lineNum += 1
    }
    return array
}

struct RbxObject{
    init(name: String, className: String, propertyStart: Int, propertyEnd: Int, childStart: Int? = nil, childEnd: Int? = nil) {
        self.name = name
        self.className = className
        self.propertyStart = propertyStart
        self.propertyEnd = propertyEnd
        self.childStart = childStart
        self.childEnd = childEnd
    }
    let name: String
    let className: String
    let propertyStart: Int
    let propertyEnd: Int
    let childStart: Int?
    let childEnd: Int?
}

struct PropertyInfo{
    let type: String
    let value: Any
}

let multiInObject = ["CoordinateFrame", "Vector3", "PhysicalProperties", "Color3", "Vector2"]

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}
