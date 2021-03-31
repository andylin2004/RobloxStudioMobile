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

func parseToDict(data: String) -> Array<RbxObject>{
    let toParse = data.split(whereSeparator: \.isNewline)
    
    var dataSet: Array<RbxObject> = []
    
    var tempProperties: Dictionary<String, PropertyInfo> = [:]
    
    var tempName: String = ""
    
    var lineNum = 3
    while lineNum < toParse.count-4{
        var line = toParse[lineNum]
        if line.replacingOccurrences(of: "\t", with: "") == "</Item>"{
            //skip
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
            if toParse[lineNum].replacingOccurrences(of: "\t", with: "") != "</Items>"{
                let result = parseToDict(data: toParse, startAtLine: lineNum+1)
                lineNum = result.resumingAt
                dataSet.append(RbxObject(name: tempName, properties: tempProperties, Items: result.resultTable))
                tempName = ""
                tempProperties = [:]
            }
            
        }
        else if line.replacingOccurrences(of: "\t", with: "").prefix(1) == "<"{
            let parseLine = line[line.index(after: line.firstIndex(of: "<")!)..<line.firstIndex(of: ">")!]
            let parseSplit = parseLine.split(separator: " ")
            
//            print(line)
            tempName = String(parseSplit[1])
            
        }
        lineNum += 1
    }
    loading = false
    return dataSet
}

private func parseToDict(data: Array<Substring>, startAtLine: Int) -> (resultTable: Array<RbxObject>, resumingAt: Int){
    var lineNum = startAtLine
    
    var dataSet: Array<RbxObject> = []
    
    var tempProperties: Dictionary<String, PropertyInfo> = [:]
    
    var tempName: String = ""
    
    while lineNum < data.count - 4 && data[lineNum].replacingOccurrences(of: "\t", with: "") != "</Item>"{
        var line = data[lineNum]
//        print(line)
//        print(lineNum)
        if line.replacingOccurrences(of: "\t", with: "") == "<Properties>"{
            lineNum += 1
            while data[lineNum].replacingOccurrences(of: "\t", with: "") != "</Properties>"{
                line = data[lineNum]
//                print(line)
                
                if line.contains("<![CDATA["){
                    lineNum += 1
                    while !data[lineNum].contains("]]>"){
                        line += data[lineNum]
                        lineNum += 1
                    }
                }
                let parseLine = line[line.index(after: line.firstIndex(of: "<")!)..<line.firstIndex(of: ">")!]
                let parseSplit = parseLine.split(separator: " ")
                
                let propertyType = String(parseSplit[0])
                
                if multiInObject.contains(propertyType) {
                    var flag: Dictionary<String, Any> = [:]
                    
                    lineNum += 1
                    while data[lineNum].replacingOccurrences(of: "\t", with: "") != "</"+propertyType+">"{
//                        print(toParse[lineNum])
                        line = data[lineNum]
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
            if data[lineNum].replacingOccurrences(of: "\t", with: "") != "</Items>"{
                let result = parseToDict(data: data, startAtLine: lineNum+1)
                lineNum = result.resumingAt
                dataSet.append(RbxObject(name: tempName, properties: tempProperties, Items: result.resultTable))
                tempName = ""
                tempProperties = [:]
            }
        }
        else if line.replacingOccurrences(of: "\t", with: "").prefix(1) == "<"{
            let parseLine = line[line.index(after: line.firstIndex(of: "<")!)..<line.firstIndex(of: ">")!]
            let parseSplit = parseLine.split(separator: " ")
            
            tempName = String(parseSplit[1])
            
            let result = parseToDict(data: parseSplit, startAtLine: lineNum+1)
            lineNum = result.resumingAt
            dataSet.append(RbxObject(name: tempName, properties: tempProperties, Items: result.resultTable))
            tempName = ""
            tempProperties = [:]
        }
        lineNum += 1
    }
    
    return (dataSet, lineNum-1)
}

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

extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}
