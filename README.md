JXPod
========

[![Build Status][GitHubActionBadge]][ActionsLink]
[![Swift5 compatible][Swift5Badge]][Swift5Link] 
![Platform][SwiftPlatforms]
<!-- [![](https://tokei.rs/b1/github/jectivex/JXPod)](https://github.com/jectivex/JXPod) -->

JXPod is a cross-platform framework that enables you to export
properties of your Swift classes to an embedded JavaScript environment,
enabling your app to provide scriptable extensions.

This project is currently an umbrella for a variety of `JXPod` projects.
Until version 1.0.0 is release, minor version increases can contain
API-breaking changes.

Browse the [API Documentation].

JXPod is built on top of [JXBridge][], which
provides a fluent way to expose Swift properties
and functions to an embedded JavaScript context.

## Installation

### Swift Package Manager

The [Swift Package Manager][] is a tool for managing the distribution of
Swift code.

Add the following to your `Package.swift` file:

  ```swift
  dependencies: [
      .package(url: "https://github.com/jectivex/JXPod", from: "1.0.0")
  ]
  ```

[Swift Package Manager]: https://swift.org/package-manager

## Communication

[See the planning document] for a roadmap and existing feature requests.

 - Need **help** or have a **general question**? [Ask on Stack
   Overflow][] (tag `swiftjack`).
 - Found a **bug** or have a **feature request**? [Open an issue][].
 - Want to **contribute**? [Submit a pull request][].

[See the planning document]: /Documentation/Planning.md
[Read the contributing guidelines]: ./CONTRIBUTING.md#contributing
[Ask on Stack Overflow]: https://stackoverflow.com/questions/tagged/swiftjack
[Open an issue]: https://github.com/jectivex/JXPod/issues/new
[Submit a pull request]: https://github.com/jectivex/JXPod/fork

## Dependencies

 - [JXBridge][] Bridging between JXKit and native
 - [JXKit][] Cross-platform Swift interface to JavaScriptCore
 - [JavaScriptCore][]: Cross-platform JavaScript engine
 - [OpenCombine][] Cross-platform Combine implementation
 - [Fair][] Utilities

[ProjectLink]: https://github.com/jectivex/JXPod
[ActionsLink]: https://github.com/jectivex/JXPod/actions
[API Documentation]: https://www.jective.org/JXPod/documentation/jxpod/

[Swift]: https://swift.org/
[OpenCombine]: https://github.com/OpenCombine/OpenCombine
[Fair]: https://github.com/fair-ground/Fair
[JXPod]: https://github.com/jectivex/JXPod
[JXBridge]: https://github.com/jectivex/JXBridge
[Jack]: https://github.com/jectivex/Jack
[JXKit]: https://github.com/jectivex/JXKit
[JavaScriptCore]: https://trac.webkit.org/wiki/JavaScriptCore

[GitHubActionBadge]: https://img.shields.io/github/workflow/status/jectivex/JXPod/JXPod%20CI

[Swift5Badge]: https://img.shields.io/badge/swift-5-orange.svg?style=flat
[Swift5Link]: https://developer.apple.com/swift/
[SwiftPlatforms]: https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20tvOS%20|%20Linux-teal.svg

