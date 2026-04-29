// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Athena",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Athena", targets: ["Athena"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Athena",
            dependencies: [],
            path: ".",
            exclude: [
                ".git",
                ".build",
                "swiftly.pkg",
                "README.md",
                "README.iOS.md",
                "LICENSE",
                "# Athena – AI Prompt Contract.md",
                "# Athena – Demo Storyboard (VibeCon).md",
                "# Athena – MVP Architecture & Feature Sp.md"
            ],
            sources: [
                "AthenaApp.swift",
                "Models",
                "Services",
                "ViewModels",
                "Views"
            ]
        )
    ]
)
