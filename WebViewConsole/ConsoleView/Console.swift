//
//  Console.swift
//  WebViewConsoleView
//
//  Created by Hubert Zhang on 2019/10/17.
//

import UIKit

extension ConsoleMessageSource {
    func labelColor() -> UIColor {
        if #available(iOS 13.0, *) {
            switch self {
            case .user:
                return .systemBlue
            case .navigation:
                return .systemGreen
            default:
                return .label
            }
        } else {
            switch self {
            case .user:
                return .blue
            case .navigation:
                return .green
            default:
                return .black
            }
        }
    }

    func image() -> UIImage? {
        switch self {
        case .navigation:
            return UIImage(named: "navigation", in: viewControllerBundle, compatibleWith: nil)
        case .user:
            return UIImage(named: "user", in: viewControllerBundle, compatibleWith: nil)
        case .userResult:
            return UIImage(named: "userResult", in: viewControllerBundle, compatibleWith: nil)
        default:
            return nil
        }
    }
}

extension ConsoleMessageLevel {
    func labelColor() -> UIColor {
        if #available(iOS 13.0, *) {
            switch self {
            case .debug:
                return UIColor.systemBlue
            case .warning:
                return UIColor { (traitCollection) -> UIColor in
                    if traitCollection.userInterfaceStyle == .light {
                        return UIColor(red: 0.4, green: 0.3, blue: 0, alpha: 1)
                    } else {
                        return UIColor(red: 1, green: 1, blue: 0, alpha: 1)
                    }
                }

            case .error:
                return UIColor.systemRed
            default:
                return UIColor.label
            }
        } else {
            switch self {
            case .debug:
                return UIColor.blue
            case .warning:
                return UIColor(red: 0.4, green: 0.3, blue: 0, alpha: 1)
            case .error:
                return UIColor.red
            default:
                return UIColor.black
            }
        }
    }

    func backgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            switch self {
            case.debug:
                return UIColor.systemBlue.withAlphaComponent(0.2)
            case .warning:
                return UIColor.systemYellow.withAlphaComponent(0.2)
            case .error:
                return UIColor.systemRed.withAlphaComponent(0.2)
            default:
                return UIColor.systemBackground
            }
        } else {
            switch self {
            case.debug:
                return UIColor.blue.withAlphaComponent(0.2)
            case .warning:
                return UIColor.yellow.withAlphaComponent(0.2)
            case .error:
                return UIColor.red.withAlphaComponent(0.2)
            default:
                return UIColor.white
            }
        }
    }
    func image() -> UIImage? {
        switch self {
        case .debug:
            return UIImage(named: "info", in: viewControllerBundle, compatibleWith: nil)
        case .warning:
            return UIImage(named: "warning", in: viewControllerBundle, compatibleWith: nil)
        case .error:
            return UIImage(named: "error", in: viewControllerBundle, compatibleWith: nil)
        default:
            return nil
        }
    }
}

public protocol ConsoleMessageProtocol {
    func getSource() -> ConsoleMessageSource
    func getLevel() -> ConsoleMessageLevel
    func getMessage() -> String
    func getLocation() -> String
}

public protocol Console {
    func count() -> Int

    func messages(at index: Int) -> ConsoleMessageProtocol

    func commit(command: String)

    func clearMessages()

    func set(delegate: WebViewConsoleDataDelegate)
}

protocol ConsoleSuggestionProvider {
    func fetchSuggestions(for text: String, cursorIndex: Int, completion: @escaping ([String], NSRange) -> Void)
}
