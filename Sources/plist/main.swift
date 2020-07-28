import Foundation
import ArgumentParser

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
        if  let xml = FileManager.default.contents(atPath: file),
            let plist = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil),
            var dictionary = plist as? [String: Any] {
            
            if addValues {
                dictionary[key] = value
            } else if let _ = dictionary[key] {
                dictionary[key] = value
            }
            
            if output {
                print(dictionary)
            }
        } else {
            print("File (\(file)) doesn't exist")
        }
    }
}


PList.main()

