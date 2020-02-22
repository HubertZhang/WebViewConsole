//
//  WebViewConsole.swift
//  WebViewConsole
//
//  Created by Hubert Zhang on 2019/11/11.
//

import Foundation
import WebKit

let resourceBundle = Bundle(url: Bundle(for: ConsoleMessageHandler.self).url(forResource: "Console", withExtension: "bundle")!)!
let wrapperScript = try! String(contentsOf: resourceBundle.url(forResource: "object_wrapper", withExtension: "js")!)

public protocol WebViewConsoleDataDelegate: class {
    func messagesUpdated()
    func messageArrived()
}

public class WebViewConsole {
    var name: String

    public weak var delegate: WebViewConsoleDataDelegate?
    weak var webView: WKWebView?

    public convenience init() {
        self.init(name: "__webViewConsole")
    }

    public init(name: String) {
        self.name = name
    }

    public func setup(webView: WKWebView) {
        self.webView = webView
        let messageHandler = ConsoleMessageHandler()
        messageHandler.delegate = self
        webView.configuration.userContentController.add(messageHandler, name: name)
    }

    public func setupUserScript(to webView: WKWebView) {
        webView.configuration.userContentController.addUserScript(ConsoleMessageHandler.script(with: name))
    }

    public var clearedMessages: [ConsoleMessage] = []
    public var messages: [ConsoleMessage] = []

    public func clearMessages() {
        clearedMessages.append(contentsOf: messages)
        messages = []

        self.messageUpdated()
    }

    public func commit(command: String) {
        self.add(message: ConsoleMessage(source: .user, level: .none, message: command))
        self.webView?.evaluateJavaScript(WebViewConsole.wrap(command: command), completionHandler: { (result, error) in
            if let error = error {
                let error = error as NSError
                let message = error.userInfo["WKJavaScriptExceptionMessage"] as? String ?? error.localizedDescription

                self.add(message: ConsoleMessage(source: .userResult, level: .error, message: message))
                return
            }
            guard let result = result as? NativeJavaScriptObject else {
                return
            }

            self.add(message: ConsoleMessage(source: .userResult, level: .none, message: [result.convert()]))
        })
    }

    static func wrap(command: String) -> String {
        var t = command
        t = t.replacingOccurrences(of: "\\u000d\\u000a", with: "\n")
        t = t.replacingOccurrences(of: "\n", with: "\\n")
        t = t.replacingOccurrences(of: "\"", with: "\\\"")
        return """
        (\(wrapperScript))(eval("\(t)"))
        """
    }

    var completionCommand: String = {
        return try! String(contentsOf: resourceBundle.url(forResource: "console_prompt_completion", withExtension: "js")!)
    }()

    public func fetchSuggestions(for text: String, cursorIndex: Int, completion: @escaping ([String], NSRange) -> Void) {
        if self.webView == nil {
            completion([], NSRange(location: NSNotFound, length: 0))
            return
        }

        if text.count == 0 {
            completion([], NSRange(location: NSNotFound, length: 0))
            return
        }

        let command = "\(self.completionCommand)('\(encodeToBase64(string: text))', \(cursorIndex))"
        self.webView?.evaluateJavaScript(command, completionHandler: { (result, error) in
            if error != nil {
                print(error.debugDescription)
                completion([], NSRange(location: NSNotFound, length: 0))
                return
            }
            guard let resultDict = result as? Dictionary<String, Any> else {
                completion([], NSRange(location: NSNotFound, length: 0))
                return
            }
            guard let suggestions = resultDict["completions"] as? [String] else {
                completion([], NSRange(location: NSNotFound, length: 0))
                return
            }
            guard let tokenStart = resultDict["token_start"] as? NSNumber else {
                completion([], NSRange(location: NSNotFound, length: 0))
                return
            }
            guard let tokenEnd = resultDict["token_end"] as? NSNumber else {
                completion([], NSRange(location: NSNotFound, length: 0))
                return
            }

            completion(suggestions, NSRange(location: tokenStart.intValue, length: tokenEnd.intValue - tokenStart.intValue))
        })
    }

    func add(message: ConsoleMessage) {
        self.messages.append(message)
        self.messageUpdated()
    }

    func messageUpdated() {
        self.delegate?.messagesUpdated()
    }
}

extension WebViewConsole: ConsoleMessageHandlerDelegate {
    public func didReceive(message: ConsoleMessage) {
        self.add(message: message)
    }

    public func shouldClearMessage() {
        self.clearMessages()
    }

}
