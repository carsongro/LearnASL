// swift-tools-version: 5.9

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Learn ASL",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "Learn ASL",
            targets: ["AppModule"],
            bundleIdentifier: "Carson-Gross.LearnASLAlphabet",
            teamIdentifier: "HV69QD4SV2",
            displayVersion: "1.0",
            bundleVersion: "2",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.pink),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(purposeString: "This app uses the camera utilize hand poses")
            ],
            appCategory: .education
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        )
    ]
)
