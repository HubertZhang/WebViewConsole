//
//  bridges.swift
//  WebViewConsoleView
//
//  Created by Hubert Zhang on 2019/10/18.
//

import UIKit
import WebViewConsole

func mapToDictionary<Key, Value>(seq: [Key], mapper: ((Key) -> Value)) -> [Key: Value] {
    return Dictionary(seq.map({ (key) -> (Key, Value) in
        return (key, mapper(key))
    }), uniquingKeysWith: { (first, _) in first })
}

let sources = [ConsoleMessageSource].init(arrayLiteral: .js, .navigation, .native, .user, .userResult)
let levels = [ConsoleMessageLevel].init(arrayLiteral: .none, .debug,
    .log,
    .warning,
    .error)

let sourceLableColors = mapToDictionary(seq: sources) { source -> UIColor in
    if #available(iOS 13.0, *) {
        switch source {
        case .user:
            return .systemBlue
        case .navigation:
            return .systemGreen
        default:
            return .label
        }
    } else {
        switch source {
        case .user:
            return .blue
        case .navigation:
            return .green
        default:
            return .black
        }
    }
}

let sourceImages = mapToDictionary(seq: sources) { source -> UIImage? in
    switch source {
    case .navigation:
        return UIImage(named: "navigation", in: viewControllerBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    case .user:
        return UIImage(named: "user", in: viewControllerBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    case .userResult:
        return UIImage(named: "userResult", in: viewControllerBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    default:
        return nil
    }
}

let levelLabelColors = mapToDictionary(seq: levels) { level -> UIColor in
    if #available(iOS 13.0, *) {
        switch level {
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
        switch level {
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

let levelBackgroundColors = mapToDictionary(seq: levels) { level -> UIColor in
    if #available(iOS 13.0, *) {
        switch level {
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
        switch level {
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

let levelImages = mapToDictionary(seq: levels) { level -> UIImage? in
    switch level {
    case .debug:
        return UIImage(named: "debug", in: viewControllerBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    case .warning:
        return UIImage(named: "warning", in: viewControllerBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    case .error:
        return UIImage(named: "error", in: viewControllerBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    default:
        return nil
    }
}

extension ConsoleMessageSource {
    var labelColor: UIColor {
        return sourceLableColors[self]!
    }

    var image: UIImage? {
        return sourceImages[self]!
    }
}

extension ConsoleMessageLevel {
    var labelColor: UIColor {
        return levelLabelColors[self]!
    }

    var backgroundColor: UIColor {
        return levelBackgroundColors[self]!
    }
    var image: UIImage? {
        return levelImages[self]!
    }
}

extension ConsoleMessage: ConsoleMessageProtocol {
    public func getIcon() -> UIImage? {
        if source == .js {
            return level.image
        } else {
            return source.image
        }
    }

    public func getLableColor() -> UIColor? {
        if source == .js {
            return level.labelColor
        } else if source == .navigation {
            if level == .warning {
                return level.labelColor
            } else {
                return source.labelColor
            }
        } else {
            return source.labelColor
        }
    }

    public func getBackgroundColor() -> UIColor? {
        if source == .js {
            return level.backgroundColor
        }
        return nil
    }

    public func getTitle() -> String {
        return location
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
    public func count() -> Int {
        return self.messages.count
    }

    public func messages(at index: Int) -> ConsoleMessageProtocol {
        return self.messages[index]
    }
}

extension WebViewConsole: ConsoleSuggestionProvider {

}
