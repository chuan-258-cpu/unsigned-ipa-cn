import Foundation

let fm = FileManager.default
let directory = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let source = directory.appendingPathComponent("ipa/sideload/fchat_8.0.71_weixin.ipa")
let profile = directory.appendingPathComponent("signing/profiles/FChat_Beta_AppStore_20261009.mobileprovision")
let bundleID = "com.paxcapital.chatbeta"
let teamID = "K242QGHJQZ"
let identity = "0AE301C7AF9ACE7152E38E2C56DFF456FB221CB9"
let build = CommandLine.arguments.dropFirst().first ?? "1"
let outputDirectory = directory.appendingPathComponent("ipa/testflight")
let output = outputDirectory.appendingPathComponent("fchat_8.0.71_appstore_b\(build).ipa")
let archivedOutput = directory.appendingPathComponent("archive/testflight-b\(build)/\(output.lastPathComponent)")
let staging = fm.temporaryDirectory.resolvingSymlinksInPath().appendingPathComponent("fchat-appstore-\(UUID().uuidString)")

struct BuildError: Error, CustomStringConvertible {
    let description: String
}

@discardableResult
func run(_ executable: String, _ arguments: [String]) throws -> Data {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = FileHandle.standardError
    try process.run()
    let result = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else {
        throw BuildError(description: "\(executable) failed: \(process.terminationStatus)")
    }
    return result
}

func plist(_ data: Data) throws -> [String: Any] {
    guard let value = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
        throw BuildError(description: "Invalid property list")
    }
    return value
}

func writePlist(_ value: [String: Any], _ url: URL) throws {
    let data = try PropertyListSerialization.data(fromPropertyList: value, format: .xml, options: 0)
    try data.write(to: url, options: .atomic)
}

do {
    guard build.range(of: "^[1-9][0-9]{0,3}$", options: .regularExpression) != nil else {
        throw BuildError(description: "Build must be an integer from 1 through 9999")
    }
    guard !fm.fileExists(atPath: output.path), !fm.fileExists(atPath: archivedOutput.path) else {
        throw BuildError(description: "Output already exists; choose a new build number")
    }
    let profileData = try run("/usr/bin/security", ["cms", "-D", "-i", profile.path])
    let decodedProfile = try plist(profileData)
    let profileEntitlements = decodedProfile["Entitlements"] as? [String: Any] ?? [:]
    let appIdentifier = "\(teamID).\(bundleID)"
    guard profileEntitlements["application-identifier"] as? String == appIdentifier,
          profileEntitlements["com.apple.developer.team-identifier"] as? String == teamID,
          profileEntitlements["get-task-allow"] as? Bool == false,
          profileEntitlements["beta-reports-active"] as? Bool == true,
          decodedProfile["ProvisionedDevices"] == nil,
          decodedProfile["ProvisionsAllDevices"] == nil,
          let expiration = decodedProfile["ExpirationDate"] as? Date, expiration > Date() else {
        throw BuildError(description: "Profile is not a matching, valid App Store distribution profile")
    }
    try fm.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
    try fm.createDirectory(at: staging, withIntermediateDirectories: true)
    try run("/usr/bin/ditto", ["-x", "-k", source.path, staging.path])
    let app = staging.appendingPathComponent("Payload/WeChat.app")
    // Store-generated FairPlay metadata is not allowed in developer upload packages.
    let metadataEnumerator = fm.enumerator(atPath: app.path)!
    var removedStoreMetadata = [String]()
    for case let relativePath as String in metadataEnumerator {
        if (relativePath as NSString).lastPathComponent == "SC_Info" {
            removedStoreMetadata.append(relativePath)
            metadataEnumerator.skipDescendants()
        }
    }
    for relativePath in removedStoreMetadata {
        try fm.removeItem(at: app.appendingPathComponent(relativePath))
    }
    let infoURL = app.appendingPathComponent("Info.plist")
    var info = try plist(Data(contentsOf: infoURL))
    info["CFBundleIdentifier"] = bundleID
    info["CFBundleVersion"] = build
    // The source lost its asset-catalog declaration despite retaining the AppIcon assets.
    info["CFBundleIcons"] = ["CFBundlePrimaryIcon": [
        "CFBundleIconName": "AppIcon", "CFBundleIconFiles": ["AppIcon60x60"]
    ]]
    info["CFBundleIcons~ipad"] = ["CFBundlePrimaryIcon": [
        "CFBundleIconName": "AppIcon", "CFBundleIconFiles": ["AppIcon60x60", "AppIcon76x76"]
    ]]
    info.removeValue(forKey: "CFBundleIconFiles")
    if let modes = info["UIBackgroundModes"] as? [String] {
        info["UIBackgroundModes"] = modes.filter { $0 != "network-authentication" }
    }
    try writePlist(info, infoURL)
    try fm.copyItem(at: profile, to: app.appendingPathComponent("embedded.mobileprovision"))
    let entitlements: [String: Any] = [
        "application-identifier": appIdentifier,
        "com.apple.developer.team-identifier": teamID,
        "beta-reports-active": true,
        "get-task-allow": false,
        "keychain-access-groups": [appIdentifier]
    ]
    let entitlementsURL = staging.appendingPathComponent("distribution.entitlements")
    try writePlist(entitlements, entitlementsURL)
    let frameworks = try fm.contentsOfDirectory(at: app.appendingPathComponent("Frameworks"),
        includingPropertiesForKeys: nil).filter { $0.pathExtension == "framework" }.sorted { $0.path < $1.path }
    let mainExecutable = info["CFBundleExecutable"] as! String
    var executablePaths = [mainExecutable]
    var executables = [app.appendingPathComponent(mainExecutable)]
    for framework in frameworks {
        let frameworkInfo = try plist(Data(contentsOf: framework.appendingPathComponent("Info.plist")))
        guard let name = frameworkInfo["CFBundleExecutable"] as? String else {
            throw BuildError(description: "Framework is missing an executable: \(framework.path)")
        }
        executables.append(framework.appendingPathComponent(name))
        executablePaths.append("Frameworks/\(framework.lastPathComponent)/\(name)")
    }
    // Fail on unexpected nested code so nothing remains signed by the original team.
    let expected = Set(executablePaths)
    let enumerator = fm.enumerator(atPath: app.path)!
    for case let relativePath as String in enumerator {
        let url = app.appendingPathComponent(relativePath)
        if ["appex", "xpc", "app"].contains(url.pathExtension) {
            throw BuildError(description: "Nested executable bundle requires its own profile: \(url.path)")
        }
        guard try url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true else { continue }
        let handle = try FileHandle(forReadingFrom: url)
        let magic = handle.readData(ofLength: 4)
        try handle.close()
        let machOMagic = [Data([0xcf, 0xfa, 0xed, 0xfe]), Data([0xce, 0xfa, 0xed, 0xfe]),
                          Data([0xca, 0xfe, 0xba, 0xbe]), Data([0xbe, 0xba, 0xfe, 0xca])]
        if machOMagic.contains(magic), !expected.contains(relativePath) {
            throw BuildError(description: "Unexpected Mach-O code: \(url.path)")
        }
    }
    for executable in executables {
        try fm.setAttributes([.posixPermissions: 0o755], ofItemAtPath: executable.path)
    }
    try run("/usr/bin/xattr", ["-cr", app.path])
    for framework in frameworks {
        try run("/usr/bin/codesign", ["--force", "--sign", identity, "--timestamp=none", framework.path])
    }
    try run("/usr/bin/codesign", ["--force", "--sign", identity, "--timestamp=none",
        "--generate-entitlement-der", "--entitlements", entitlementsURL.path, app.path])
    try run("/usr/bin/codesign", ["--verify", "--deep", "--strict", "--verbose=2", app.path])
    for framework in frameworks {
        try run("/usr/bin/codesign", ["--verify", "--strict", framework.path])
    }
    try run("/usr/bin/ditto", ["-c", "-k", "--norsrc", "--noextattr", "--noqtn", "--keepParent",
        staging.appendingPathComponent("Payload").path, output.path])
    try run("/usr/bin/unzip", ["-tq", output.path])
    let archivePaths = String(data: try run("/usr/bin/unzip", ["-Z1", output.path]), encoding: .utf8)!
        .split(separator: "\n")
    guard !archivePaths.contains(where: { $0.split(separator: "/").contains("SC_Info") }) else {
        throw BuildError(description: "Disallowed SC_Info metadata remains in the final IPA")
    }
    let digest = String(data: try run("/usr/bin/shasum", ["-a", "256", output.path]), encoding: .utf8)!
        .split(separator: " ").first.map(String.init)!
    let manifest: [String: Any] = [
        "preparedAt": ISO8601DateFormatter().string(from: Date()),
        "status": "Locally verified distribution re-sign; not uploaded or Apple-validated",
        "appStoreConnectAppleID": "6820996068", "appStoreConnectName": "FChat Beta",
        "bundleID": bundleID, "teamID": teamID,
        "version": info["CFBundleShortVersionString"] as! String, "build": build,
        "displayName": info["CFBundleDisplayName"] as! String,
        "profileUUID": decodedProfile["UUID"] as! String,
        "profileExpiration": ISO8601DateFormatter().string(from: expiration),
        "signingCertificateSHA1": identity,
        "sourceIPA": source.lastPathComponent, "outputIPA": output.lastPathComponent,
        "sha256": digest, "entitlements": entitlements,
        "frameworkCount": frameworks.count,
        "removedStoreMetadata": removedStoreMetadata.sorted().map { "Payload/WeChat.app/" + $0 },
        "signedExecutables": executablePaths.map { "Payload/WeChat.app/" + $0 },
        "changes": ["Bundle ID", "CFBundleVersion", "AppIcon catalog declaration",
            "Removed all disallowed SC_Info metadata before re-signing",
            "Removed unsupported network-authentication background mode",
            "Embedded company distribution profile", "Re-signed all frameworks and main app",
            "Replaced original team-specific entitlements with company profile permissions"],
        "notVerified": ["Apple upload validation", "TestFlight processing and review",
            "Runtime behavior under new bundle ID", "Third-party redistribution rights",
            "Encryption export compliance", "Privacy manifest completeness"]
    ]
    let manifestURL = outputDirectory.appendingPathComponent("fchat_8.0.71_appstore_b\(build).json")
    try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys])
        .write(to: manifestURL, options: .atomic)
    print("IPA: \(output.path)\nSHA-256: \(digest)\nManifest: \(manifestURL.path)")
    print("Staging: \(staging.path)")
} catch {
    fputs("Build failed: \(error)\nStaging retained at: \(staging.path)\n", stderr)
    exit(1)
}
