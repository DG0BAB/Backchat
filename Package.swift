// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Name of this Package
let packageName = "backchat"

// Package creation
let package = Package(name: packageName)

// Products define the executables and libraries produced by a package, and make them visible to other packages.
package.products = [.library(name: packageName, targets: [packageName])]
package.platforms = [.iOS(.v13), .macOS(.v10_15)]
package.dependencies = [
	.package(url: "https://github.com/mxcl/PromiseKit", from: "6.10.0"),
//	.package(url: "git@github.com:DG0BAB/Clause.git", .path("develop")),
	.package(name: "Clause", path: "../../Clause/ClausePackage"),
//	.package(url: "git@github.com:DG0BAB/Fehlerteufel.git", .branch("develop")),
	.package(name: "Fehlerteufel", path: "../../Fehlerteufel/FTPackage"),
]
package.targets = [
	.target(name: packageName, dependencies: ["Clause", "Fehlerteufel", "PromiseKit"], path: "Sources"),
	.testTarget(name: "\(packageName)Tests", dependencies: [Target.Dependency(stringLiteral: packageName)]),
]
