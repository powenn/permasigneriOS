//
//  DirectoryPath.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/6.
//

import UIKit

// Referencee from Lakr Aream on 2022/1/7.

let signerAppPath = URL(fileURLWithPath: "/Applications/permasigneriOS.app")

let availableDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

let documentsDirectory = availableDirectories[0].appendingPathComponent("permasigneriOS")

let tmpDirectory = documentsDirectory.appendingPathComponent("tmp")

let DebApplicationsDirectory = tmpDirectory.appendingPathComponent("deb/Applications")

let DebDebianDirectory = tmpDirectory.appendingPathComponent("deb/DEBIAN")

let OutputPackageDirectory = documentsDirectory.appendingPathComponent("Package")

func setPathAndTmp() {
    if documentsDirectory.path.count < 2 {
        fatalError("malformed system resources")
    }
    // Everytime app opened try create Document folder and tmp
    try? FileManager.default.createDirectory(
        at: documentsDirectory,
        withIntermediateDirectories: true,
        attributes: nil
    )
    // Delete tmp and recreate
    try? FileManager.default.removeItem(at: tmpDirectory)
    try? FileManager.default.createDirectory(
        at: tmpDirectory,
        withIntermediateDirectories: true,
        attributes: nil
    )
    FileManager.default.changeCurrentDirectoryPath(documentsDirectory.path)
}
