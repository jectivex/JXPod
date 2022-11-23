import Foundation
import JXBridge
import JXKit

public class FilePod: JXPod, JXModule {
    let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public var metadata: JXPodMetaData {
        JXPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }
    
    public let namespace: JXNamespace = "file"
    
    public func register(with registry: JXRegistry) throws {
        try registry.register {
            JXBridgeBuilder(type: FileManager.self)
                .var.temporaryDirectory { $0.temporaryDirectory.path }
                .var.currentDirectory { \.currentDirectoryPath }
                .func.changeCurrentDirectory { FileManager.changeCurrentDirectoryPath }
                .func.contentsOfDirectory { FileManager.contentsOfDirectory(atPath:) }
                .func.createDirectory { try $0.createDirectory(atPath: $1, withIntermediateDirectories: $2) }
                .func.remove { FileManager.removeItem(atPath:) }
                .func.copy { FileManager.copyItem(atPath:toPath:) }
                .func.move { FileManager.moveItem(atPath:toPath:) }
                .func.exists { FileManager.fileExists(atPath:) }
                .bridge
        }
    }
    
    public func initialize(in context: JXContext) throws {
        try context.global.integrate(fileManager, namespace: namespace)
    }
}