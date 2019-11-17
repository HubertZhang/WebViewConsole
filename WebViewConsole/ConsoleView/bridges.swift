//
//  bridges.swift
//  IITC-Mobile
//
//  Created by Hubert Zhang on 2019/10/18.
//  Copyright © 2019 IITC. All rights reserved.
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
                return "\(arg)"
            }.joined(separator: " ")
        }
        return "\(message)"
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
