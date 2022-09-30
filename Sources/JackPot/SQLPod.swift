import Foundation
import Jack

// MARK: SQLPod

public protocol SQLPod : JackPod {
}

// MARK: SQLitePod

#if canImport(SQLite3)
import SQLite3

open class SQLitePod : JackPod, SQLPod {
    open var metadata: JackPodMetaData {
        JackPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }

    open lazy var pod = jack()

    public init() {
    }
}
#endif

