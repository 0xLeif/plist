import Foundation
import ArgumentParser

enum PListError: Error {
    case noFile
    case noPList
    case noKey
}

struct MockPList: Codable {}

struct PList: ParsableCommand {
    @Option()
    var new = false
    
    @Option()
    var output = false
    
    @Option()
    var addValues = false
    
    @Argument()
    var filePath: String
    
    @Argument()
    var key: String?
    
    @Argument()
    var value: String?
    
    mutating func createNewFile() throws {
        if !filePath.hasPrefix(".plist") {
            filePath.append(".plist")
        }
        let contents = try PropertyListEncoder().encode(MockPList())
        // Create and add key-value
        FileManager.default.createFile(atPath: filePath, contents: contents, attributes: [:])
        
        guard let file = FileManager.default.contents(atPath: filePath) else {
            throw PListError.noFile
        }
        
        try editPList(file: file)
    }
    
    func editPList(file: Data) throws {
        guard let plist = try? PropertyListSerialization.propertyList(from: file,
                                                                      options: .mutableContainersAndLeaves,
                                                                      format: nil),
            var dictionary = plist as? [String: Any] else {
                throw PListError.noPList
        }
        
        guard let key = key else {
            throw PListError.noKey
        }
        
        if addValues {
            dictionary[key] = value
        } else if let _ = dictionary[key] {
            dictionary[key] = value
        }
        
        if output {
            print(dictionary)
        }
    }
    
    mutating func run() throws {
        guard !new else {
            return try createNewFile()
        }
        
        guard let file = FileManager.default.contents(atPath: filePath) else {
            throw PListError.noFile
        }
        
        try editPList(file: file)
    }
}


PList.main()

