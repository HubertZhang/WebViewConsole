//
//  bridges.swift
//  WebViewConsoleView
//
//  Created by Hubert Zhang on 2019/10/18.
//

import Foundation

extension ConsoleMessage: ConsoleMessageProtocol {
    public func getSource() -> ConsoleMessageSource {
        return source
    }

    public func getLevel() -> ConsoleMessageLevel {
        return level
    }

    public func getMessage() -> String {
        if let args = message as? Array<JavaScriptObject> {
            return args.map { (arg) -> String in
                return arg.toString()
            }.joined(separator: " ")
        }
        return message.toString()
    }

    public func getLocation() -> String {
        return location
    }
}

extension WebViewConsole: Console {
    public func set(delegate: WebViewConsoleDataDelegate) {
        self.delegate = delegate
    }

    public func count() -> Int {
        return self.messages.count
    }

    public func messages(at index: Int) -> ConsoleMessageProtocol {
        return self.messages[index]
    }
}

extension WebViewConsole: ConsoleSuggestionProvider {

}
