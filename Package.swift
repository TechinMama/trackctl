// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Athena",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
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
                "LICENSE",
                "# Athena – AI Prompt Contract.md",
                "# Athena – Demo Storyboard (VibeCon).md",
                "# Athena – MVP Architecture & Feature Sp.md",
                "Social-Lessons-Learned-Toolkit.md",
                "VibeCon-Execution-Playbook.md",
                "project.yml",
                ".github",
                "Tests",
                "AthenaApp.swift",
                "Theme",
                "Views"
            ],
            sources: [
                "Models",
                "Services",
                "ViewModels"
            ]
        ),
        .testTarget(
            name: "AthenaTests",
            dependencies: ["Athena"],
            path: "Tests/AthenaTests"
        )
    ]
)
