import Foundation
import JXBridge
import JXKit
import FairCore

/// A module with the capability of having its scripts and resources dynamically loaded from an external source.
///
/// The transport scheme and loading mechaism is to be implemented by the host container.
public protocol JXDynamicModule : JXModule {
    /// The path to the locally-installed folder containing the scripts and resources for the app.
    static var localURL: URL? { get }

    /// The logical path to the remote root folder in the source archive whose file and folder layout matches the structure of the localURL.
    static var remoteURL: URL? { get }
}

/// The source repository that hosts the tagged versions of the dynamic module source.
public protocol JXDynamicModuleSource {
    /// A reference to a version of the module, which can then be converted into an archive URL
    associatedtype Ref : Hashable

    /// Information about the tags for the given module source
    typealias RefInfo = (ref: Ref, date: Date)

    /// The available refs for this module source
    var refs: [RefInfo] { get async throws }

    /// Returns the URL for the zipball of the repository at the given tag or branch.
    /// - Parameters:
    ///   - ref: the ref for the archive
    /// - Returns: the archive URL for the given named ref
    func archiveURL(for ref: Ref) -> URL
}


extension JXDynamicModule {
    /// Returns a HubSource for this module, throwing an error if it is not a supported .git URL
    public static var hubSource: HubModuleSource {
        get throws {
            guard let remoteBase = Self.remoteURL?.baseURL else {
                throw URLError(.badURL)
            }
            guard remoteBase.pathExtension == "git" else {
                throw URLError(.unsupportedURL) // only .git URL bases are accepted
            }

            return try HubModuleSource(repository: remoteBase)
        }
    }
}

/// A module source that uses a GitHub repository's tags and zipball archive URL for checking versions.
public struct HubModuleSource : JXDynamicModuleSource {
    // GitHub:
    //  repository: https://github.com/ORG/REPO.git
    //  tag list: https://github.com/ORG/REPO/tags.atom
    //  download: https://github.com/ORG/REPO/archive/refs/tags/TAG.zip

    // Gitea:
    //  repository: https://try.gitea.io/ORG/REPO.git
    //  tag list: https://try.gitea.io/ORG/REPO/tags.atom
    //  download: https://try.gitea.io/ORG/REPO/archive/TAG.zip

    // GitLab:
    //  repository: https://gitlab.com/ORG/REPO.git
    //  tag list: ???
    //  download: https://gitlab.com/ORG/REPO/-/archive/TAG/REPO-TAG.zip

    public let repository: URL // e.g., https://github.com/Magic-Loupe/PetStore.git

    public enum Ref : Hashable {
        case tag(String)
        case branch(String)

        /// Returns the tag or branch name
        public var type: String {
            switch self {
            case .tag: return "tag"
            case .branch: return "branch"
            }
        }

        /// Returns the tag or branch name
        public var name: String {
            switch self {
            case .tag(let str): return str
            case .branch(let str): return str
            }
        }

        /// If this is a tag and the string is a semantic version (e.g., 1.2.3), then return it.
        public var semver: SemVer? {
            guard case .tag = self else { return nil }
            return SemVer(string: self.name)
        }
    }

    /// Throws an error if the repository provider is not supported.
    public init(repository: URL) throws {
        self.repository = repository
        if !isHost("github.com") {
            throw URLError(.unsupportedURL)
        }
    }

    func url(_ relativeTo: String) -> URL {
        // convert "/PetStore.git" to "/PetStore"
        repository.deletingPathExtension().appendingPathComponent(relativeTo, isDirectory: false)
    }

    /// Returns true if the repository is managed by the given host
    func isHost(_ domain: String) -> Bool {
        ("." + (repository.host ?? "")).hasSuffix("." + domain)
    }

    /// Returns the URL for the zipball of the repository at the given tag or branch.
    /// - Parameters:
    ///   - name: the tag or branch name
    ///   - tag: whether the given name is for a tag or branch
    /// - Returns: the archive URL for the given named tag/branch
    public func archiveURL(for ref: Ref) -> URL {
        let name: String
        let tag: Bool
        switch ref {
        case .tag(let nm):
            name = nm
            tag = true
        case .branch(let nm):
            name = nm
            tag = false
        }

        if isHost("github.com") { // GitHub style
            // Tag: https://github.com/ORG/REPO/archive/refs/tags/TAG.zip
            // Branch: https://github.com/ORG/REPO/archive/refs/heads/BRANCH.zip
            return url("archive/refs")
                .appendingPathComponent(tag ? "tags" : "heads", isDirectory: true)
                .appendingPathComponent(name, isDirectory: false)
                .appendingPathExtension("zip")
        } else if isHost("gitlab.com") { // GitLab-style: same URL for branch and tag
            let repo = repository.pathComponents.dropFirst().first ?? "" // extract REPO from https://gitlab.com/ORG/REPO/…
            // Tag: https://gitlab.com/ORG/REPO/-/archive/TAG/REPO-TAG.zip
            // Branch: https://gitlab.com/ORG/REPO/-/archive/BRANCH/REPO-BRANCH.zip
            return url("-/archive")
                .appendingPathComponent(name, isDirectory: true)
                .appendingPathComponent(repo + "-" + name, isDirectory: false) // any name seems to work here, but the web UI names it repo-name.zip
                .appendingPathExtension("zip")
        } else { // Gitea-style: the same URL regardless of whether it is a branch or a tag
            // Tag: https://try.gitea.io/ORG/REPO/archive/TAG.zip
            // Branch: https://try.gitea.io/ORG/REPO/archive/BRANCH.zip
            return url("archive")
                .appendingPathComponent(name, isDirectory: false)
                .appendingPathExtension("zip")
        }
    }

    public var refs: [RefInfo] {
        get async throws {
            // TODO: this only works for GitHub … need to determine feed format for GitLab and Gitea
            let (data, _) = try await URLSession.shared.fetch(request: URLRequest(url: url("tags.atom")))
            let feed = try AtomFeed.parse(xml: data)
            return feed.feed.entry?.collectionMulti.map({ (Ref.tag($0.title), $0.updated) }) ?? []
        }
    }

    /// All the tags that can be parsed as a `SemVer`.
    public var tagVersions: [SemVer] {
        get async throws {
            try await refs.map(\.ref).compactMap(\.semver)
        }
    }
}

extension AtomFeed {
    /// Parses the given XML as an RSS feed
    static func parse(xml: Data) throws -> Self {
        try AtomFeed(jsum: XMLNode.parse(data: xml).jsum(), options: .init(dateDecodingStrategy: .iso8601))
    }
}

/// A minimal RSS feed implementation for parsing GitHub tag feeds like https://github.com/Magic-Loupe/PetStore/tags.atom
struct AtomFeed : Decodable {
    var feed: Feed

    struct Feed : Decodable {
        var id: String // tag:github.com,2008:https://github.com/Magic-Loupe/PetStore/releases
        var title: String
        var updated: Date

        /// The list of links, which when converted from XML might be translated as a single or multiple element
        typealias LinkList = ElementOrArray<Link> // i.e. XOr<Link>.Or<[Link]>
        var link: LinkList

        struct Link : Decodable {
            var type: String // text/html
            var rel: String // alternate
            var href: String // https://github.com/Magic-Loupe/PetStore/releases
        }

        /// The list of entries, which when converted from XML might be translated as a single or multiple element
        typealias EntryList = ElementOrArray<Entry> // i.e. XOr<Entry>.Or<[Entry]>
        var entry: EntryList?

        struct Entry : Decodable {
            var id: String // tag:github.com,2008:Repository/584868941/0.0.2
            var title: String // 0.0.2
            var updated: Date // "2023-01-03T20:28:34Z"
            var link: LinkList // https://github.com/Magic-Loupe/PetStore/releases/tag/0.0.2

//            var author: Author
//
//            struct Author : Decodable {
//                var name: String
//            }
//
//            var thumbnail: Thumbnail
//
//            struct Thumbnail : Decodable {
//                var height: String // 30
//                var width: String // 30
//                var url: URL // https://avatars.githubusercontent.com/u/659086?s=60&v=4
//            }
        }
    }
}
