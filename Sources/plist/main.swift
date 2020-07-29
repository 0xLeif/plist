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
    var output = true
    
    @Option()
    var addValues = true
    
    @Option()
    var editMode = false
    
    @Argument()
    var filePath: String
    
    @Argument()
    var key: String?
    
    @Argument()
    var value: String?
    
    mutating func createNewFile() throws {
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
        
        if let key = key {
            if addValues {
                dictionary[key] = value
            } else if let _ = dictionary[key] {
                dictionary[key] = value
            }

            (dictionary as NSDictionary).write(toFile: filePath, atomically: true)
        }
        
        if output {
            print(dictionary)
        }
    }
    
    mutating func run() throws {
        if !filePath.hasSuffix(".plist") {
            filePath.append(".plist")
        }
        
        guard !new else {
            return try createNewFile()
        }
        
        guard let file = FileManager.default.contents(atPath: filePath) else {
            throw PListError.noFile
        }
        
        try editPList(file: file)
        
        if editMode {
            while true {
                guard let command = readLine(strippingNewline: true) else {
                    break
                }
                
                switch command {
                case "new":
                    print("Add new value")
                case "delete":
                    print("Delete value")
                default:
                    print("Not a value command\n:")
                }
            }
        }
    }
}


PList.main()

