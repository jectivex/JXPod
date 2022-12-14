import Foundation
import JXBridge
import JXKit

public class FilePod: JXPod, JXModule {
    public static let namespace: JXNamespace = "file"
    let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public static var metadata: JXPodMetaData {
        JXPodMetaData(source: URL(string: "https://github.com/jectivex/JXPod.git")!)
    }

    public func register(with registry: JXRegistry) throws {
        try registry.register {
            JXBridgeBuilder(type: FileManager.self)
                .var.temporaryDirectory { $0.temporaryDirectory.path }
                .var.currentDirectory { \.currentDirectoryPath }
                .func.changeCurrentDirectory { FileManager.changeCurrentDirectoryPath }
                .func.contentsOfDirectory { FileManager.contentsOfDirectory(atPath:) }
                .func.createDirectory { try $0.createDirectory(atPath: $1, withIntermediateDirectories: $2) }
                .func.createFile { $0.createFile(atPath: $1, contents: $2, attributes: $3) }
                .func.remove { FileManager.removeItem(atPath:) }
                .func.copy { FileManager.copyItem(atPath:toPath:) }
                .func.move { FileManager.moveItem(atPath:toPath:) }
                .func.exists { $0.fileExists(atPath: $1) }
                .bridge
        }
    }
    
    public func initialize(in context: JXContext) throws {
        try context.global.integrate(fileManager, namespace: Self.namespace)
    }
}
