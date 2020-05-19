// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Name of this Package
let packageName = "backchat"

// Package creation
let package = Package(name: packageName)

// Products define the executables and libraries produced by a package, and make them visible to other packages.
package.products = [.library(name: packageName, targets: [packageName])]
package.platforms = [.iOS(.v13)]
package.dependencies = [.package(url: "https://github.com/mxcl/PromiseKit", from: "6.10.0")]
package.targets = [
	.target(name: packageName, dependencies: ["PromiseKit"], path: "Sources"),
	.testTarget(name: "\(packageName)Tests", dependencies: [Target.Dependency(stringLiteral: packageName)]),
]
