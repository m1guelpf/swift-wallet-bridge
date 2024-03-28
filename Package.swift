// swift-tools-version:5.9
import PackageDescription

let package = Package(
	name: "wallet-bridge",
	platforms: [
		.macOS(.v13),
	],
	dependencies: [
		.package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),
		.package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
	],
	targets: [
		.executableTarget(
			name: "App",
			dependencies: [
				.product(name: "Vapor", package: "vapor"),
				.product(name: "Redis", package: "redis"),
			]
		),
	]
)
