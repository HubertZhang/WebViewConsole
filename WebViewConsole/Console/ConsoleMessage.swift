//
//  ConsoleMessage.swift
//  WebViewConsole
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
    case warning = "warn"
    case error
}

public struct ConsoleMessage {
    public var source: ConsoleMessageSource
    public var level: ConsoleMessageLevel
    public var message: JavaScriptObject
    public var caller: String?
    public var lineNumber: String?
    public var file: String?

    public var location: String {
        if caller != nil {
            return caller!
        }
        guard let filePath = file else {
            if source == .user || source == .userResult {
                return ""
            }
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
