//
//  ConsoleMessageHandler.swift
//  WebviewConsole
//
//  Created by Hubert Zhang on 2019/11/11.
//

import Foundation
import WebKit

public protocol ConsoleMessageHandlerDelegate: class {
    func didReceive(message: ConsoleMessage)
    func shouldClearMessage()
}

func location(from filePath: String?, lineNumber: NSNumber?) -> String {
    guard let filePath = filePath else {
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
    return "\(filename):\(lineNumber.int64Value)"
}

public class ConsoleMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: ConsoleMessageHandlerDelegate?

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        print("--- Message received ---\nName: \(message.name)\nArg:\n\(message.body)\n------")
        guard let m = message.body as? Dictionary<String, Any> else {
            return
        }
        let functionName = m["func"] as? String ?? "log"
        let args = m["args"] as? NSArray ?? NSArray()
        let file = m["file"] as? String
        let lineNumber = m["lineno"] as? String
        switch functionName {
        case "clear":
            self.delegate?.shouldClearMessage()
        case "assert":
            let condition = args.firstObject as? NativeJavaScriptObject ?? NSNull()
            if (condition.convert().boolValue) {
                return
            }
            var message = "Assertion failed: "
            if args.count > 1 {
                message += args.dropFirst().map { (arg) -> String in
                    guard let arg = arg as? NativeJavaScriptObject else {
                        return "[object Unknown]"
                    }
                    return arg.convert().toString()
                }.joined(separator: " ")
            } else {
                message += "console.assert"
            }
            self.delegate?.didReceive(message: ConsoleMessage(source: .js, level: .error, message: message, lineNumber: lineNumber, file: file))

        default:
            let level = ConsoleMessageLevel(rawValue: functionName) ?? .none
            let message = args.convert()
            self.delegate?.didReceive(message: ConsoleMessage(source: .js, level: level, message: message, lineNumber: lineNumber, file: file))
        }
    }

    public static func script(with name: String) -> WKUserScript {
        let scriptPath = resourceBundle.url(forResource: "console_bridge", withExtension: "js")
        let script = try! String(contentsOf: scriptPath!)
        return WKUserScript(source:
            "\(script)({handler: \"\(name)\", wrapper: \(wrapperScript)})",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false)
    }
}
