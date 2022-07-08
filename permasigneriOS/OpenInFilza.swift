//
//  ExportFileAlert.swift
//  permasigneriOS
//
//  Created by 蕭博文 on 2022/7/7.
//

import Foundation
import SwiftUI
import UIKit


func checkFilza() -> Bool {
    let urlString = "filza:///var/mobile//Documents"
    if let url = URL(string: urlString),UIApplication.shared.canOpenURL(url) {
        return true
    }
    return false
}
