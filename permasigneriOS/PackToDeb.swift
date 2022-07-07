//
//  PackToDeb.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/6.
//

import Foundation
import AuxiliaryExecute

var ProgressDescribe:String = ""
var OutputDebFilePath:String = ""

func prepareDebFolder() {
    ProgressDescribe = "Preparing deb file..."
    // Create Deb Folder and Output Folder
    try? FileManager.default.createDirectory(
        at: DebApplicationsDirectory,
        withIntermediateDirectories: true,
        attributes: nil
    )
    try? FileManager.default.createDirectory(
        at: DebDebianDirectory,
        withIntermediateDirectories: true,
        attributes: nil
    )
    try? FileManager.default.createDirectory(
        at: OutputPackageDirectory,
        withIntermediateDirectories: true,
        attributes: nil
    )
}

func resetDebFolder() {
    try? FileManager.default.removeItem(at: tmpDirectory.appendingPathComponent("deb"))
}



func copyResourcesAndReplace() {
    // Control File
    ProgressDescribe = "Copying deb file scripts and control..."
    if let controlFileURL = Bundle.main.url(forResource: "control", withExtension: "") {
        try? FileManager.default.copyItem(at: controlFileURL, to: DebDebianDirectory.appendingPathComponent("control"))
        do {
            var newControlFileText = try String(contentsOf: controlFileURL, encoding: .utf8)
            newControlFileText = newControlFileText.replacingOccurrences(of: "{APP_NAME}", with: app_name)
            newControlFileText = newControlFileText.replacingOccurrences(of: "{APP_BUNDLE}", with: app_bundle)
            newControlFileText = newControlFileText.replacingOccurrences(of: "{APP_VERSION}", with: app_version)
            newControlFileText = newControlFileText.replacingOccurrences(of: "{APP_MIN_IOS}", with: app_min_ios)
            newControlFileText = newControlFileText.replacingOccurrences(of: "{APP_AUTHOR}", with: app_author)
            try newControlFileText.write(to: DebDebianDirectory.appendingPathComponent("control"), atomically: true, encoding: .utf8)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    // Postinst File
    if let postinstFileURL = Bundle.main.url(forResource: "postinst", withExtension: "") {
        try? FileManager.default.copyItem(at: postinstFileURL, to: DebDebianDirectory.appendingPathComponent("postinst"))
        do {
            var newPostinstFileText = try String(contentsOf: postinstFileURL, encoding: .utf8)
            newPostinstFileText = newPostinstFileText.replacingOccurrences(of: "{APP_NAME}", with: app_name)
            try newPostinstFileText.write(to: DebDebianDirectory.appendingPathComponent("postinst"), atomically: true, encoding: .utf8)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    // Postrm File
    if let postrmFileURL = Bundle.main.url(forResource: "postrm", withExtension: "") {
        try? FileManager.default.copyItem(at: postrmFileURL, to: DebDebianDirectory.appendingPathComponent("postrm"))
        do {
            var newPostrmFileText = try String(contentsOf: postrmFileURL, encoding: .utf8)
            newPostrmFileText = newPostrmFileText.replacingOccurrences(of: "{APP_NAME}", with: app_name)
            try newPostrmFileText.write(to: DebDebianDirectory.appendingPathComponent("postrm"), atomically: true, encoding: .utf8)
        }
        catch {
            print(error.localizedDescription)
        }
    }
}

func copyAppContent() {
    ProgressDescribe = "Copying app files..."
    try? FileManager.default.copyItem(at: payloadPath.appendingPathComponent(appNameInPayload), to: DebApplicationsDirectory.appendingPathComponent(appNameInPayload))
}

func ChangeDebPermisson() {
    ProgressDescribe = "Changing deb file scripts permissions..."

    // Scripts parts
    AuxiliaryExecute.local.bash(command: "chmod 0755 /var/mobile/Documents/permasigneriOS/tmp/deb/DEBIAN/postrm")
    AuxiliaryExecute.local.bash(command: "chmod 0755 /var/mobile/Documents/permasigneriOS/tmp/deb/DEBIAN/postinst")
    // app_executable
    AuxiliaryExecute.local.bash(command: "chmod 0755 /var/mobile/Documents/permasigneriOS/tmp/deb/Applications/\(appNameInPayload)\(app_executable!)")
}

func SignAppWithLdid() {
    ProgressDescribe = "Signing with ldid..."

    AuxiliaryExecute.local.bash(command: "ldid -S/Applications/permasigneriOS.app/app.entitlements -M -Upassword -K/Applications/permasigneriOS.app/dev_certificate.p12 /var/mobile/Documents/permasigneriOS/tmp/deb/Applications/\(appNameInPayload)")
}

func PackToDeb(inputFileName:String) {
    ProgressDescribe = "Packaging the deb file..."
    
    AuxiliaryExecute.local.bash(command: "dpkg-deb -Zxz --root-owner-group -b /var/mobile/Documents/permasigneriOS/tmp/deb /var/mobile/Documents/permasigneriOS/Package/\(inputFileName.replacingOccurrences(of: ".ipa", with: "")).deb")
}

func CheckDebBuild(inputFileName:String) -> Bool {
    if FileManager.default.fileExists(atPath: OutputPackageDirectory.appendingPathComponent("\(inputFileName.replacingOccurrences(of: ".ipa", with: "")).deb").path) {
        OutputDebFilePath = OutputPackageDirectory.appendingPathComponent("\(inputFileName.replacingOccurrences(of: ".ipa", with: "")).deb").path
        return true
    } else {
        return false}
}


func permanentSignButtonFunc(FileName:String) {
    resetDebFolder()
    prepareDebFolder()
    copyResourcesAndReplace()
    copyAppContent()
    ChangeDebPermisson()
    SignAppWithLdid()
    PackToDeb(inputFileName: FileName)
}
