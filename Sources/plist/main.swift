import Foundation
import ArgumentParser

enum PListError: Error {
    case noFile
    case noPList
}

struct PList: ParsableCommand {
    @Argument()
    var file: String
    
    @Option()
    var output = false
    
    @Option()
    var addValues = false
    
    @Argument()
    var key: String
    
    @Argument()
    var value: String?
    
    mutating func run() throws {
        guard let filePath = FileManager.default.contents(atPath: file) else {
            throw PListError.noFile
        }
        
        guard let plist = try? PropertyListSerialization.propertyList(from: filePath,
                                                                      options: .mutableContainersAndLeaves,
                                                                      format: nil),
            var dictionary = plist as? [String: Any] else {
                throw PListError.noPList
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
}


PList.main()

