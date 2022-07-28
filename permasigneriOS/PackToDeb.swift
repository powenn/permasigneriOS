//
//  PackToDeb.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/6.
//

import Foundation
import AuxiliaryExecute

class Progress: ObservableObject {
    private init() { }
    static let shared = Progress()
    
    var OutputDebFilePath = ""
    //    @Published var Percent = 1.0
    @Published var ProgressingDescribe = ""
    @Published var CustomDebDescription = ""
    
    var AppNameDir = ""
    
    func resetDebFolder() {
        try? FileManager.default.removeItem(at: tmpDirectory.appendingPathComponent("deb"))
    }
    
    func prepareDebFolder() {
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
    
    func copyResourcesAndReplace() {
        // Control File
        if let controlFileURL = Bundle.main.url(forResource: "control", withExtension: "") {
            try? FileManager.default.copyItem(at: controlFileURL, to: DebDebianDirectory.appendingPathComponent("control"))
            do {
                var newControlFileText = try String(contentsOf: controlFileURL, encoding: .utf8)
                newControlFileText = newControlFileText.replacingOccurrences(of: "{APP_NAME}", with: CheckApp.shared.custom_app_name)
                newControlFileText = newControlFileText.replacingOccurrences(of: "{APP_BUNDLE}", with: CheckApp.shared.custom_app_bundle)
                newControlFileText = newControlFileText.replacingOccurrences(of: "{APP_VERSION}", with: CheckApp.shared.app_version)
                newControlFileText = newControlFileText.replacingOccurrences(of: "{APP_MIN_IOS}", with: CheckApp.shared.app_min_ios)
                newControlFileText = newControlFileText.replacingOccurrences(of: "{APP_AUTHOR}", with: CheckApp.shared.app_author)
                if CustomDebDescription != "" {
                    newControlFileText = newControlFileText.replacingOccurrences(of: "App resigned with Linus Henze's CoreTrust bypass so it doesn't expire.", with: CustomDebDescription)
                }
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
                newPostinstFileText = newPostinstFileText.replacingOccurrences(of: "{APP_NAME}", with: CheckApp.shared.custom_app_name)
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
                newPostrmFileText = newPostrmFileText.replacingOccurrences(of: "{APP_NAME}", with: CheckApp.shared.custom_app_name)
                try newPostrmFileText.write(to: DebDebianDirectory.appendingPathComponent("postrm"), atomically: true, encoding: .utf8)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        // Entitilements
        // copy origin to tmp dir then rewrite and sign with it
        if let entitlementsFileURL = Bundle.main.url(forResource: "entitlements", withExtension: ".plist") {
            try? FileManager.default.copyItem(at: entitlementsFileURL, to: tmpDirectory.appendingPathComponent("entitlements.plist"))
            
            let plistDict = NSMutableDictionary(contentsOfFile: tmpDirectory.appendingPathComponent("entitlements.plist").path)
            plistDict!.setObject(CheckApp.shared.custom_app_bundle, forKey: "application-identifier" as NSCopying)
            plistDict!.write(toFile: tmpDirectory.appendingPathComponent("entitlements.plist").path, atomically: false)
            
            plistDict!.setObject(["group.\(CheckApp.shared.custom_app_bundle)"], forKey: "com.apple.security.application-groups" as NSCopying)
            plistDict!.write(toFile: tmpDirectory.appendingPathComponent("entitlements.plist").path, atomically: false)
            
            plistDict!.setObject([CheckApp.shared.custom_app_bundle], forKey: "keychain-access-groups" as NSCopying)
            plistDict!.write(toFile: tmpDirectory.appendingPathComponent("entitlements.plist").path, atomically: false)
        }
        // Info.plist
        // get Info in plist file
        if CheckApp.shared.app_bundle != CheckApp.shared.custom_app_bundle {
            AppNameDir = CheckApp.shared.appNameInPayload.replacingOccurrences(of: CheckApp.shared.app_name, with: CheckApp.shared.custom_app_name)
            let InfoPlistPathInTmpPayload = CheckApp.shared.payloadPath.appendingPathComponent("\(CheckApp.shared.appNameInPayload)/Info.plist")
            if let PlistScriptFileURL = Bundle.main.url(forResource: "Plist", withExtension: "sh") {
                try? FileManager.default.copyItem(at: PlistScriptFileURL, to: tmpDirectory.appendingPathComponent("Plist.sh"))
                do {
                    var newPlistScriptText = try String(contentsOf: PlistScriptFileURL, encoding: .utf8)
                    newPlistScriptText = newPlistScriptText.replacingOccurrences(of: "{MY_PLIST_PATH}", with: InfoPlistPathInTmpPayload.path)
                    newPlistScriptText = newPlistScriptText.replacingOccurrences(of: "{OLD_VALUE}", with: CheckApp.shared.app_bundle)
                    newPlistScriptText = newPlistScriptText.replacingOccurrences(of: "{NEW_VALUE}", with: CheckApp.shared.custom_app_bundle)
                    try newPlistScriptText.write(to: tmpDirectory.appendingPathComponent("Plist.sh"), atomically: true, encoding: .utf8)
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            let plistDict = NSMutableDictionary(contentsOfFile: InfoPlistPathInTmpPayload.path)
            plistDict!.setObject(CheckApp.shared.custom_app_name, forKey: "CFBundleDisplayName" as NSCopying)
            plistDict!.write(toFile: CheckApp.shared.payloadPath.appendingPathComponent("\(CheckApp.shared.appNameInPayload)/Info.plist").path, atomically: false)
            
            AuxiliaryExecute.local.bash(command: "bash /var/mobile/Documents/permasigneriOS/tmp/Plist.sh")
        } else {
            AppNameDir = CheckApp.shared.appNameInPayload
        }
    }
    
    func copyAppContent() {
        try? FileManager.default.copyItem(at: CheckApp.shared.payloadPath.appendingPathComponent(CheckApp.shared.appNameInPayload), to: DebApplicationsDirectory.appendingPathComponent(AppNameDir))
    }
    
    func ChangeDebPermisson() {
        // Scripts parts
        AuxiliaryExecute.local.bash(command: "chmod 0755 /var/mobile/Documents/permasigneriOS/tmp/deb/DEBIAN/postrm")
        AuxiliaryExecute.local.bash(command: "chmod 0755 /var/mobile/Documents/permasigneriOS/tmp/deb/DEBIAN/postinst")
        // app_executable
        AuxiliaryExecute.local.bash(command: "chmod 0755 /var/mobile/Documents/permasigneriOS/tmp/deb/Applications/\(AppNameDir)/\(CheckApp.shared.app_executable!)")
        
        // -------------------------- //
        AuxiliaryExecute.local.bash(command: "chmod -R 04755 /var/mobile/Documents/permasigneriOS/tmp/deb/Applications/\(AppNameDir)")
        // -------------------------- //
    }
    
    func SignAppWithLdid() {
        AuxiliaryExecute.local.bash(command: "ldid -S/var/mobile/Documents/permasigneriOS/tmp/entitlements.plist -M -K/Applications/permasigneriOS.app/dev_certificate.p12 /var/mobile/Documents/permasigneriOS/tmp/deb/Applications/\(AppNameDir)/\(CheckApp.shared.app_executable!)")
        AuxiliaryExecute.local.bash(command: "chmod 0755 /var/mobile/Documents/permasigneriOS/tmp/deb/Applications/\(AppNameDir)/\(CheckApp.shared.app_executable!)")
        
        // ldid sign example.app
        AuxiliaryExecute.local.bash(command: "ldid -S/var/mobile/Documents/permasigneriOS/tmp/entitlements.plist -M -K/Applications/permasigneriOS.app/dev_certificate.p12 /var/mobile/Documents/permasigneriOS/tmp/deb/Applications/\(AppNameDir)")
        
    }
    
    func CheckFrameWorkDirExist() {
        // If exist .framework or .dylib then sign them
        let FrameWorkFolderPath = DebApplicationsDirectory.appendingPathComponent("\(AppNameDir)/Frameworks").path
        var frameworkBinaryName:String = ""
        if FileManager.default.fileExists(atPath: FrameWorkFolderPath) {
            
            let Contents = try? FileManager.default.contentsOfDirectory(atPath: FrameWorkFolderPath)
            for content in Contents! {
                if content.hasSuffix(".framework") {
                    frameworkBinaryName = content.replacingOccurrences(of: ".framework", with: "")
                    
                    
                    if FileManager.default.fileExists(atPath: FrameWorkFolderPath.appending("\(content)/\(frameworkBinaryName)")) {
                        AuxiliaryExecute.local.bash(command: "ldid -K/Applications/permasigneriOS.app/dev_certificate.p12 \(FrameWorkFolderPath)/\(content)/\(frameworkBinaryName)")
                    }
                    
                    
                }
                if content.hasSuffix(".dylib"){
                    AuxiliaryExecute.local.bash(command: "ldid -K/Applications/permasigneriOS.app/dev_certificate.p12 /var/mobile/Documents/permasigneriOS/tmp/deb/Applications/\(AppNameDir)/Frameworks/\(content)")
                    AuxiliaryExecute.local.bash(command: "chmod 0755 /var/mobile/Documents/permasigneriOS/tmp/deb/Applications/\(AppNameDir)/Frameworks/\(content)")
                }
            }
        }
    }
    
    
    func PackToDeb() {
        AuxiliaryExecute.local.bash(command: "dpkg-deb -Zxz --root-owner-group -b /var/mobile/Documents/permasigneriOS/tmp/deb /var/mobile/Documents/permasigneriOS/Package/\(CheckApp.shared.fileName.replacingOccurrences(of: ".ipa", with: "")).deb")
    }
    
    func CheckDebBuild() -> Bool {
        if FileManager.default.fileExists(atPath: OutputPackageDirectory.appendingPathComponent("\(CheckApp.shared.fileName.replacingOccurrences(of: ".ipa", with: "")).deb").path) {
            OutputDebFilePath = OutputPackageDirectory.appendingPathComponent("\(CheckApp.shared.fileName.replacingOccurrences(of: ".ipa", with: "")).deb").path
            return true
        } else {
            return false}
    }
    
    func permanentSignButtonFunc() {
        //        Percent = 0.0
        ProgressingDescribe = "[1/8] Clearing folder"
        resetDebFolder()
        
        //        Percent += 0.125
        ProgressingDescribe = "[2/8] Preparing folder"
        prepareDebFolder()
        
        //        Percent += 0.125
        ProgressingDescribe = "[3/8] Copying Resources"
        copyResourcesAndReplace()
        
        //        Percent += 0.125
        ProgressingDescribe = "[4/8] Copying app contents"
        copyAppContent()
        
        //        Percent += 0.125
        ProgressingDescribe = "[5/8] Setting permissions"
        ChangeDebPermisson()
        
        //        Percent += 0.125
        ProgressingDescribe = "[6/8] Signing with ldid"
        SignAppWithLdid()
        
        //        Percent += 0.125
        ProgressingDescribe = "[7/8] Checking frameworks"
        CheckFrameWorkDirExist()
        
        //        Percent += 0.125
        ProgressingDescribe = "[8/8] Packing to deb"
        PackToDeb()
        
        ProgressingDescribe = ""
        //        Percent = 1.0
    }
}
