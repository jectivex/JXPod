import Foundation
import Jack

// MARK: FilePod

// fs.mkdir('/tmp/dir')

open class FilePod : JackPod {
    let fm: FileManager

    public init(fm: FileManager = .default) {
        self.fm = fm
    }

    public var metadata: JackPodMetaData {
        JackPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }

    public lazy var pod = jack()

    @Jack("fileExists") var _fileExists = fileExists
    func fileExists(atPath path: String) -> Bool {
        fm.fileExists(atPath: path)
    }

    @Jack("createDirectory") var _createDirectory = createDirectory
    func createDirectory(atPath path: String, withIntermediateDirectories dirs: Bool) throws {
        try fm.createDirectory(atPath: path, withIntermediateDirectories: dirs)
    }
}


