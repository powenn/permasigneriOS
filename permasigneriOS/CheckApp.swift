//
//  CheckAppInsidePayload.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/6.
//

import Foundation
import ZipArchive

class CheckApp: ObservableObject {
    
    private init() { }
    
    static let shared = CheckApp()
    
    @Published var appNameInPayload:String = ""
    @Published var payloadPath:URL = URL(fileURLWithPath: "")
    
    @Published var fileName:String = ""
    @Published var filePath:String = ""
    
    @Published var destination = URL(fileURLWithPath: "")
    @Published var fileDir = URL(fileURLWithPath: "")
    
    // App Info vars
    @Published var config: [String: Any]?
    @Published var InfoPlistPath = URL(string: "")
    @Published var app_name:String = ""
    @Published var app_bundle:String = ""
    @Published var app_version:String = ""
    @Published var app_min_ios:String = ""
    @Published var app_author:String = ""
    
    @Published var app_executable:String? = nil
    @Published var validInfoPlist:Bool = false
    // ----------------------------
    
    func extractIpa() {
        do {
            destination  = tmpDirectory.appendingPathComponent(fileName.replacingOccurrences(of: ".ipa", with: ".zip"))
            fileDir = tmpDirectory.appendingPathComponent(fileName.replacingOccurrences(of: ".ipa", with: ""))
            
            payloadPath = fileDir.appendingPathComponent("Payload")
            
            try FileManager.default.copyItem(atPath: filePath, toPath: destination.path)
            try SSZipArchive.unzipFile(atPath: destination.path, toDestination: fileDir.path, overwrite: true, password: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getInfoPlistValue() {
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
    
    func checkIsIpaPayloadValid() -> Bool {
        // check .app in Payload
        if FileManager.default.fileExists(atPath: payloadPath.path) {
            let Contents = try? FileManager.default.contentsOfDirectory(atPath: payloadPath.path)
            for content in Contents! {
                if content.hasSuffix(".app") {
                    appNameInPayload = content
                    return true
                }
            }
        }
        return false
    }
    
    func checkInfoPlist() -> Bool {
        if FileManager.default.fileExists(atPath: InfoPlistPath!.path) {
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
    
}
