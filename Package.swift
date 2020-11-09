// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Name of this Package
let packageName = "backchat"

let package = Package(name: packageName)

package.products = [
	.library(name: packageName,
			 targets: [packageName])
]

package.platforms = [
	.iOS(.v13),
	.macOS(.v10_15)
]

package.defaultLocalization = "de"

package.dependencies = [
	.package(url: "https://github.com/mxcl/PromiseKit", from: "6.10.0"),
//	.package(url: "git@github.com:DG0BAB/Clause.git", .path("develop")),
	.package(name: "PetiteLogger", path: "../../PetiteLogger/PLPackage"),
	.package(name: "Clause", path: "../../Clause/ClausePackage"),
//	.package(url: "git@github.com:DG0BAB/Fehlerteufel.git", .branch("develop")),
	.package(name: "Fehlerteufel", path: "../../Fehlerteufel/FTPackage"),
]
 
let targetDependencies: [Target.Dependency] = [
	"PetiteLogger",
	"Clause",
	"Fehlerteufel",
	"PromiseKit"
]

package.targets = [
	.target(name: packageName,
			dependencies: targetDependencies,
			path: "Sources",
			resources: [Resource.process("Resources")]),

	.testTarget(name: "\(packageName)Tests",
		dependencies: [Target.Dependency(stringLiteral: packageName)])
]
