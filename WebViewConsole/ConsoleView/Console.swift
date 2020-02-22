//
//  Console.swift
//  WebViewConsoleView
//
//  Created by Hubert Zhang on 2019/10/17.
//

import UIKit

public protocol ConsoleMessageProtocol {
    func getMessage() -> String
    func getLocation() -> String
    func getIcon() -> UIImage?
    func getLableColor() -> UIColor?
    func getBackgroundColor() -> UIColor?
}

public protocol Console {
    func count() -> Int

    func messages(at index: Int) -> ConsoleMessageProtocol

    func commit(command: String)

    func clearMessages()
}

protocol ConsoleSuggestionProvider {
    func fetchSuggestions(for text: String, cursorIndex: Int, completion: @escaping ([String], NSRange) -> Void)
}
