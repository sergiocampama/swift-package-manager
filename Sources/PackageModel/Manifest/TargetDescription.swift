/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2014 - 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

/// The description of an individual target.
public struct TargetDescription: Equatable, Codable {

    /// The target type.
    public enum TargetType: String, Equatable, Codable {
        case regular
        case executable
        case test
        case system
        case binary
        case plugin
    }

    /// Represents a target's dependency on another entity.
    public enum Dependency: Equatable {
        case target(name: String, condition: PackageConditionDescription?)
        case product(name: String, package: String?, condition: PackageConditionDescription?)
        case byName(name: String, condition: PackageConditionDescription?)

        public static func target(name: String) -> Dependency {
            return .target(name: name, condition: nil)
        }

        public static func product(name: String, package: String? = nil) -> Dependency {
            return .product(name: name, package: package, condition: nil)
        }
    }

    public struct Resource: Codable, Equatable {
        public enum Rule: String, Codable, Equatable {
            case process
            case copy
        }

        public enum Localization: String, Codable, Equatable {
            case `default`
            case base
        }

        /// The rule for the resource.
        public let rule: Rule

        /// The path of the resource.
        public let path: String

        /// The explicit localization of the resource.
        public let localization: Localization?

        public init(rule: Rule, path: String, localization: Localization? = nil) {
            precondition(rule == .process || localization == nil)
            self.rule = rule
            self.path = path
            self.localization = localization
        }
    }

    /// The name of the target.
    public let name: String

    /// The custom path of the target.
    public let path: String?

    /// The url of the binary target artifact.
    public let url: String?

    /// The custom sources of the target.
    public let sources: [String]?

    /// The explicitly declared resources of the target.
    public let resources: [Resource]

    /// The exclude patterns.
    public let exclude: [String]

    // FIXME: Kill this.
    //
    /// Returns true if the target type is test.
    public var isTest: Bool {
        return type == .test
    }

    /// The declared target dependencies.
    public let dependencies: [Dependency]

    /// The custom public headers path.
    public let publicHeadersPath: String?

    /// The type of target.
    public let type: TargetType

    /// The pkg-config name of a system library target.
    public let pkgConfig: String?

    /// The providers of a system library target.
    public let providers: [SystemPackageProviderDescription]?
    
    /// The declared capability for a package plugin target.
    public let pluginCapability: PluginCapability?
    
    /// Represents the declared capability of a package plugin.
    public enum PluginCapability: Equatable {
        case buildTool
        case command(intent: PluginCommandIntent, permissions: [PluginPermission])
    }
    
    public enum PluginCommandIntent: Equatable, Codable {
        case documentationGeneration
        case sourceCodeFormatting
        case custom(verb: String, description: String)
    }

    public enum PluginPermission: Equatable, Codable {
        case writeToPackageDirectory(reason: String)
    }

    /// The target-specific build settings declared in this target.
    public let settings: [TargetBuildSettingDescription.Setting]

    /// The binary target checksum.
    public let checksum: String?
    
    /// The usages of package plugins by the target.
    public let pluginUsages: [PluginUsage]?

    /// Represents a target's usage of a plugin target or product.
    public enum PluginUsage: Equatable {
        case plugin(name: String, package: String?)
    }

    public init(
        name: String,
        dependencies: [Dependency] = [],
        path: String? = nil,
        url: String? = nil,
        exclude: [String] = [],
        sources: [String]? = nil,
        resources: [Resource] = [],
        publicHeadersPath: String? = nil,
        type: TargetType = .regular,
        pkgConfig: String? = nil,
        providers: [SystemPackageProviderDescription]? = nil,
        pluginCapability: PluginCapability? = nil,
        settings: [TargetBuildSettingDescription.Setting] = [],
        checksum: String? = nil,
        pluginUsages: [PluginUsage]? = nil
    ) throws {
        switch type {
        case .regular, .executable, .test:
            if url != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "url") }
            if pkgConfig != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "pkgConfig") }
            if providers != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "providers") }
            if pluginCapability != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "pluginCapability") }
            if checksum != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "checksum") }
        case .system:
            if !dependencies.isEmpty { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "dependencies") }
            if !exclude.isEmpty { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "exclude") }
            if sources != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "sources") }
            if !resources.isEmpty { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "resources") }
            if publicHeadersPath != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "publicHeadersPath") }
            if pluginCapability != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "pluginCapability") }
            if !settings.isEmpty { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "settings") }
            if checksum != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "checksum") }
            if pluginUsages != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "pluginUsages") }
        case .binary:
            if path == nil && url == nil { throw Error.binaryTargetRequiresEitherPathOrURL(targetName: name) }
            if !dependencies.isEmpty { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "dependencies") }
            if !exclude.isEmpty { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "exclude") }
            if sources != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "sources") }
            if !resources.isEmpty { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "resources") }
            if publicHeadersPath != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "publicHeadersPath") }
            if pkgConfig != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "pkgConfig") }
            if providers != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "providers") }
            if pluginCapability != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "pluginCapability") }
            if !settings.isEmpty { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "settings") }
            if pluginUsages != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "pluginUsages") }
        case .plugin:
            if url != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "url") }
            if !resources.isEmpty { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "resources") }
            if publicHeadersPath != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "publicHeadersPath") }
            if pkgConfig != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "pkgConfig") }
            if providers != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "providers") }
            if pluginCapability == nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "pluginCapability") }
            if !settings.isEmpty { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "settings") }
            if pluginUsages != nil { throw Error.disallowedPropertyInTarget(targetName: name, propertyName: "pluginUsages") }
        }

        self.name = name
        self.dependencies = dependencies
        self.path = path
        self.url = url
        self.publicHeadersPath = publicHeadersPath
        self.sources = sources
        self.exclude = exclude
        self.resources = resources
        self.type = type
        self.pkgConfig = pkgConfig
        self.providers = providers
        self.pluginCapability = pluginCapability
        self.settings = settings
        self.checksum = checksum
        self.pluginUsages = pluginUsages
    }
}

extension TargetDescription.Dependency: Codable {
    private enum CodingKeys: String, CodingKey {
        case target, product, byName
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .target(a1, a2):
            var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .target)
            try unkeyedContainer.encode(a1)
            try unkeyedContainer.encode(a2)
        case let .product(a1, a2, a3):
            var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .product)
            try unkeyedContainer.encode(a1)
            try unkeyedContainer.encode(a2)
            try unkeyedContainer.encode(a3)
        case let .byName(a1, a2):
            var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .byName)
            try unkeyedContainer.encode(a1)
            try unkeyedContainer.encode(a2)
        }
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = values.allKeys.first(where: values.contains) else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Did not find a matching key"))
        }
        switch key {
        case .target:
            var unkeyedValues = try values.nestedUnkeyedContainer(forKey: key)
            let a1 = try unkeyedValues.decode(String.self)
            let a2 = try unkeyedValues.decodeIfPresent(PackageConditionDescription.self)
            self = .target(name: a1, condition: a2)
        case .product:
            var unkeyedValues = try values.nestedUnkeyedContainer(forKey: key)
            let a1 = try unkeyedValues.decode(String.self)
            let a2 = try unkeyedValues.decodeIfPresent(String.self)
            let a3 = try unkeyedValues.decodeIfPresent(PackageConditionDescription.self)
            self = .product(name: a1, package: a2, condition: a3)
        case .byName:
            var unkeyedValues = try values.nestedUnkeyedContainer(forKey: key)
            let a1 = try unkeyedValues.decode(String.self)
            let a2 = try unkeyedValues.decodeIfPresent(PackageConditionDescription.self)
            self = .byName(name: a1, condition: a2)
        }
    }
}

extension TargetDescription.Dependency: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .byName(name: value, condition: nil)
    }
}

extension TargetDescription.PluginCapability: Codable {
    private enum CodingKeys: CodingKey {
        case buildTool, command
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .buildTool:
            try container.encodeNil(forKey: .buildTool)
        case .command(let a1, let a2):
            var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .command)
            try unkeyedContainer.encode(a1)
            try unkeyedContainer.encode(a2)
        }
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = values.allKeys.first(where: values.contains) else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Did not find a matching key"))
        }
        switch key {
        case .buildTool:
            self = .buildTool
        case .command:
            var unkeyedValues = try values.nestedUnkeyedContainer(forKey: key)
            let a1 = try unkeyedValues.decode(TargetDescription.PluginCommandIntent.self)
            let a2 = try unkeyedValues.decode([TargetDescription.PluginPermission].self)
            self = .command(intent: a1, permissions: a2)
        }
    }
}

extension TargetDescription.PluginUsage: Codable {
    private enum CodingKeys: String, CodingKey {
        case plugin
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .plugin(name, package):
            var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .plugin)
            try unkeyedContainer.encode(name)
            try unkeyedContainer.encode(package)
        }
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = values.allKeys.first(where: values.contains) else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Did not find a matching key"))
        }
        switch key {
        case .plugin:
            var unkeyedValues = try values.nestedUnkeyedContainer(forKey: key)
            let name = try unkeyedValues.decode(String.self)
            let package = try unkeyedValues.decodeIfPresent(String.self)
            self = .plugin(name: name, package: package)
        }
    }
}

import protocol Foundation.LocalizedError

private enum Error: LocalizedError, Equatable {
    case binaryTargetRequiresEitherPathOrURL(targetName: String)
    case disallowedPropertyInTarget(targetName: String, propertyName: String)
    
    var errorDescription: String? {
        switch self {
        case .binaryTargetRequiresEitherPathOrURL(let targetName):
            return "binary target '\(targetName)' neither defines neither path nor URL for its artifacts"
        case .disallowedPropertyInTarget(let targetName, let propertyName):
            return "target '\(targetName)' contains a value for disallowed property '\(propertyName)'"
        }
    }
}
