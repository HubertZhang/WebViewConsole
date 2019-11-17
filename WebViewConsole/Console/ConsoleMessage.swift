//
//  ConsoleMessage.swift
//  FBSnapshotTestCase
//
//  Created by Hubert Zhang on 2019/11/11.
//

import Foundation

public enum ConsoleMessageSource {
    case js
    case navigation
    case native
    case user
    case userResult
}

public enum ConsoleMessageLevel: String {
    case none
    case debug
    case log
    case warning
    case error
}

public struct ConsoleMessage {
    var source: ConsoleMessageSource
    var level: ConsoleMessageLevel
    var message: JavaScriptObject
    var caller: String?
    var lineNumber: String?
    var file: String?

    var location: String {
        if caller != nil {
            return caller!
        }
        guard let filePath = file else {
            return "unknown"
        }
        var filename: String = ""
        if let url = URL(string: filePath) {
            filename = url.lastPathComponent
        } else {
            filename = String(filePath.split(separator: "/").last ?? "")
        }

        guard let lineNumber = lineNumber else {
            return filename
        }
        return "\(filename):\(lineNumber)"
    }
}
