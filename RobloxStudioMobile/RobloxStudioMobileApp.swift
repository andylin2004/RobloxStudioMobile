//
//  RobloxStudioMobileApp.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftyXMLParser
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
    // Word documents are not an existing property on UTType
    static var rbxlx: UTType {
        // Look up the type from the file extension
        UTType.types(tag: "rbxlx", tagClass: .filenameExtension, conformingTo: .xml).first!
    }
}

func parseToDict(data: String){
//    let lineByLine = data.split(whereSeparator: \.isNewline)
//
//    for line in lineByLine{
//        print(line.re)
//    }
    
    let toParse = data.split(whereSeparator: \.isNewline)
    
    var dataSet: Array<RbxObject>
    
    var tempProperties: Dictionary<String, PropertyInfo> = [:]
    
    var lineNum = 3
    while lineNum < toParse.count-3{
        var line = toParse[lineNum]
        if line.replacingOccurrences(of: "\t", with: "").prefix(2) == "</"{
            //nothing
        }else if line.replacingOccurrences(of: "\t", with: "") == "<Properties>"{
            lineNum += 1
            while toParse[lineNum].replacingOccurrences(of: "\t", with: "") != "</Properties>"{
                line = toParse[lineNum]
//                print(line)
                
                if line.contains("<![CDATA["){
                    lineNum += 1
                    while !toParse[lineNum].contains("]]>"){
                        line += toParse[lineNum]
                        lineNum += 1
                    }
                }
                let parseLine = line[line.index(after: line.firstIndex(of: "<")!)..<line.firstIndex(of: ">")!]
                let parseSplit = parseLine.split(separator: " ")
                
                let propertyType = String(parseSplit[0])
                
                if multiInObject.contains(propertyType) {
                    var flag: Dictionary<String, Any> = [:]
                    
                    lineNum += 1
                    while toParse[lineNum].replacingOccurrences(of: "\t", with: "") != "</"+propertyType+">"{
//                        print(toParse[lineNum])
                        line = toParse[lineNum]
                        flag.updateValue(line[line.index(after: line.firstIndex(of: ">")!)..<line.lastIndex(of: "<")!], forKey: String(line[line.index(after: line.firstIndex(of: "<")!)..<line.firstIndex(of: ">")!]))
                        lineNum += 1
                    }
                    tempProperties.updateValue(PropertyInfo(type: "", value: flag), forKey: propertyType)
                }else{
                    let propertyName = String(parseSplit[1])
                    let propertyValue: String
                    if line.firstIndex(of: ">")! < line.lastIndex(of: "<")!{
                        propertyValue = String(line[line.index(after: line.firstIndex(of: ">")!)..<line.lastIndex(of: "<")!])
                    }else{
                        propertyValue = ""
                    }
                    let propertyInfo = PropertyInfo(type: propertyType, value: propertyValue)
                    
                    tempProperties.updateValue(propertyInfo, forKey: propertyName)
                    
                }
                lineNum += 1
            }
        }
        else if line.replacingOccurrences(of: "\t", with: "").prefix(1) == "<"{
            let parseLine = line[line.index(after: line.firstIndex(of: "<")!)..<line.firstIndex(of: ">")!]
            let parseSplit = parseLine.split(separator: " ")
        }
        lineNum += 1
    }
//    print(dataSet)
}

//private func parseToDict(data: Array<Substring>, startAtLine: Int) -> (Array<RbxObject>, Int){
//
//}

struct RbxObject{
    let name: String
    let properties: Dictionary<String, PropertyInfo>
    let Items: Array<RbxObject>
}

struct PropertyInfo{
    let type: String
    let value: Any
}

let multiInObject = ["CoordinateFrame", "Vector3", "PhysicalProperties", "Color3"]

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
