// swift-tools-version: 5.5

import PackageDescription

let package = Package(
	name: "Logic Parser",
	products: [
		.library(
			name: "LogicParser",
			targets: [
				"LogicParser"
			]
		)
	],
	dependencies: [
		.package(
			url: "https://github.com/palle-k/Covfefe.git",
			.upToNextMinor(from: "0.6.0")
		)
	],
	targets: [
		.target(
			name: "LogicParser",
			dependencies: [
				"Covfefe"
			]
		)
	]
)
