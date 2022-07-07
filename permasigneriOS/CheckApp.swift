//
//  CheckAppInsidePayload.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/6.
//

import Foundation
import ZipArchive

var appNameInPayload:String = ""
var payloadPath:URL = URL(fileURLWithPath: "")

// App Info vars
var config: [String: Any]?
var InfoPlistPath = URL(string: "")
var app_name:String = ""
var app_bundle:String = ""
var app_version:String = ""
var app_min_ios:String = ""
var app_author:String = ""
var app_executable:String? = nil
var validInfoPlist:Bool = false
// ----------------------------

var destination = URL(fileURLWithPath: "")
var fileDir = URL(fileURLWithPath: "")


func extractIpa(FileName:String, FilePath:String) {
    do {
        destination  = tmpDirectory.appendingPathComponent(FileName.replacingOccurrences(of: ".ipa", with: ".zip"))
        fileDir = tmpDirectory.appendingPathComponent(FileName.replacingOccurrences(of: ".ipa", with: ""))
        
        payloadPath = fileDir.appendingPathComponent("Payload")
        
        try FileManager.default.copyItem(atPath: FilePath, toPath: destination.path)
        try SSZipArchive.unzipFile(atPath: destination.path, toDestination: fileDir.path, overwrite: true, password: nil)
    } catch {
        print(error.localizedDescription)
    }
}

func getInfoPlistValue(InfoPlistURL:URL) {
    do {
        // get Info in plist file
        let infoPlistData = try Data(contentsOf: InfoPlistPath!)
        if let dict = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any] {
            config = dict
            // check is this Info.plist valid
            if ((config?["CFBundleExecutable"]) != nil) {
                app_executable = config?["CFBundleExecutable"] as? String
                app_name = config?["CFBundleName"] as! String
                app_bundle = config?["CFBundleIdentifier"] as! String
                app_version = config?["CFBundleShortVersionString"] as! String
                app_min_ios = config?["MinimumOSVersion"] as! String
                app_author = app_bundle.components(separatedBy: ".")[1]
                validInfoPlist = true
            } else {
                validInfoPlist = false
            }
        }
    } catch {
        print(error.localizedDescription)
    }
}

func checkIsIpaPayloadValid(_ Path:String) -> Bool {
    // check .app in Payload
    if FileManager.default.fileExists(atPath: Path) {
        let Contents = try? FileManager.default.contentsOfDirectory(atPath: Path)
        for content in Contents! {
            if content.hasSuffix(".app") {
                appNameInPayload = content
                return true
            }
        }
    }
    return false
}

func checkInfoPlist(_ Path:String) -> Bool {
    if FileManager.default.fileExists(atPath: Path) {
        return true
    }
    return false
}

func removeInvalidFile() {
    do {
        try FileManager.default.removeItem(atPath: fileDir.path)
        try FileManager.default.removeItem(atPath: destination.path)
    } catch {
        print(error.localizedDescription)
    }
}
