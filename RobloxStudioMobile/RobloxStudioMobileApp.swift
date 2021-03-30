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
    
    var dataSet: Array<Any> = []
    
    for lineNum in 0..<toParse.count{
        let line = toParse[lineNum]
        if line.contains("http://www.w3.org/2005/05/xmlmime") || line == "</roblox>"{
            continue
        }
        if line.replacingOccurrences(of: "\t", with: "").prefix(2) == "</"{
            continue
        }
        if line.replacingOccurrences(of: "\t", with: "").prefix(1) == "<"{
            let parseLine = line[line.index(after: line.firstIndex(of: "<")!)..<line.firstIndex(of: ">")!]
            let parseSplit = parseLine.split(separator: " ")
            if line.index(of: "</") != nil{
                dataSet.append(NamedArray(name: String(parseLine), array: [line[line.index(after: line.firstIndex(of: ">")!)..<line.index(of: "</")!]]))
            }else{
                dataSet.append(NamedArray(name: String(parseLine), array: parseToDict(signatureToStop: String(parseSplit.first!), array: toParse, start: lineNum)))
            }
        }
    }
//    print(dataSet)
}

func parseToDict(signatureToStop: String, array: Array<Substring>, start: Int) -> Array<Any>{
    var dataSet: Array<Any> = []
    
    var lineNum = start
    
    while lineNum < array.count{
        print(lineNum)
        let line: String = String(String(array[lineNum]))
        if array[lineNum] == "</"+signatureToStop+">"{
            return dataSet, lineNum
        }
        if array[lineNum].contains("<ProtectedString name=\"Source\"><![CDATA["){
            var script = array[lineNum]
            script.removeFirst(40)
            while !array[lineNum].contains("]]></ProtectedString>"){
                script += array[lineNum]
                lineNum += 1
            }
            var add = String(array[lineNum])
            add.removeLast(21)
            script += add
            print(script)
        }else{
            let parseLine = line[line.index(after: (line.firstIndex(of: "<")!))..<line.firstIndex(of: ">")!]
            let parseSplit = parseLine.split(separator: " ")
            if line.index(of: "</") != nil && line.index(of: "</")! >= line.firstIndex(of: ">")!{
                dataSet.append(NamedArray(name: String(parseLine), array: [line[line.index(after: line.firstIndex(of: ">")!)..<line.index(of: "</")!]]))
            }else{
                dataSet.append(NamedArray(name: String(parseLine), array: parseToDict(signatureToStop: String(parseSplit.first!), array: Array(array[lineNum..<array.count]), start: lineNum)))
            }
        }
        lineNum += 1
    }
    return dataSet, lineNum
}

struct NamedArray{
    let name: String
    let array: Array<Any>
}

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
