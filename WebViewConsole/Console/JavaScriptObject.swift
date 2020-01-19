//
//  Utility.swift
//  WebViewConsole
//
//  Created by Hubert Zhang on 2019/11/11.
//

import Foundation

protocol NativeJavaScriptObject {
    func convert() -> JavaScriptObject
}

protocol JavaScriptObject {
    var boolValue: Bool { get }
    func toString() -> String
}

class _JavaScriptUnknown: JavaScriptObject {
    func toString() -> String {
        return "<unknown>"
    }

    var boolValue: Bool {
        return false
    }
}

let JavaScriptUnknown = _JavaScriptUnknown()

class _JavaScriptUndefined: JavaScriptObject {
    func toString() -> String {
        return "<undefined>"
    }

    var boolValue: Bool {
        return false
    }
}

let JavaScriptUndefined = _JavaScriptUndefined()

extension NSNull: NativeJavaScriptObject {
    func convert() -> JavaScriptObject {
        return JavaScriptNull
    }
}

class _JavaScriptNull: JavaScriptObject {
    func toString() -> String {
        return "<null>"
    }

    var boolValue: Bool {
        return false
    }
}

let JavaScriptNull = _JavaScriptNull()

extension NSDate: NativeJavaScriptObject {
    func convert() -> JavaScriptObject {
        return self as Date
    }
}

extension Date: JavaScriptObject {
    func toString() -> String {
        return self.description
    }

    var boolValue: Bool {
        return true
    }
}

extension NSArray: NativeJavaScriptObject {
    func convert() -> JavaScriptObject {
        return map { (object) -> JavaScriptObject in
            if let object = object as? NativeJavaScriptObject {
                return object.convert()
            }
            return JavaScriptNull
        }
    }
}

typealias JavaScriptArray = Array<JavaScriptObject>

extension JavaScriptArray: JavaScriptObject {
    func toString() -> String {
        return self.description
    }

    var boolValue: Bool {
        return true
    }
}

extension NSString: NativeJavaScriptObject {
    func convert() -> JavaScriptObject {
        return self as String
    }
}

extension String: JavaScriptObject {
    func toString() -> String {
        return self
    }

    var boolValue: Bool {
        return self != ""
    }
}

typealias JavaScriptFunction = String

func addIndent(_ string: String) -> String {
    return string.split(separator: "\n").joined(separator: "    \n")
}

typealias JavaScriptDictionary = Dictionary<String, JavaScriptObject>

extension JavaScriptDictionary: JavaScriptObject {
    func toString() -> String {
        var lines = [String]()
        for key in self {
            lines.append("    \(key.key): \(addIndent(key.value.toString()))")
        }
        lines.insert("{", at: 0)
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    var boolValue: Bool {
        return true
    }
}

extension NSDictionary: NativeJavaScriptObject {
    func convert() -> JavaScriptObject {
        guard let type = self["__type"] as? String else {
            return JavaScriptUnknown
        }
        let value = self["__value"]
        switch type {
        case "undefined":
            return JavaScriptUndefined
        case "null":
            return JavaScriptNull
        case "bigint":
            return (value as? NSNumber)?.int64Value ?? Int64(0)
        case "boolean":
            return (value as? NSNumber)?.boolValue ?? false
        case "number":
            return (value as? NSNumber)?.floatValue ?? Float(0)
        case "string":
            return value as? String ?? ""
        case "date":
            return (value as? NSDate)?.convert() ?? Date.init(timeIntervalSince1970: 0)
        case "array":
            guard let value = value as? NSArray else {
                return JavaScriptUnknown
            }
            return value.map { (ele) -> JavaScriptObject in
                guard let ele = ele as? NativeJavaScriptObject else {
                    return JavaScriptUnknown
                }
                return ele.convert()
            }
        case "object":
            guard let value = value as? NSDictionary else {
                return JavaScriptUnknown
            }
            var newDict = JavaScriptDictionary()
            for key in value.allKeys {
                guard let key = key as? String else {
                    continue
                }
                guard let value = value[key] as? NativeJavaScriptObject else {
                    continue
                }
                newDict[key] = value.convert()
            }
            return newDict
        case "function":
            return value as? JavaScriptFunction ?? "<function>"
        case "stringified_object":
            return value as? String ?? ""
        default:
            return JavaScriptUnknown
        }
    }
}

extension NSNumber: NativeJavaScriptObject {
    func convert() -> JavaScriptObject {
        return JavaScriptNull
    }
}

extension Int64: JavaScriptObject {
    func toString() -> String {
        return String.init(format: "%ld", self)
    }

    var boolValue: Bool {
        return self != 0
    }
}

extension Bool: JavaScriptObject {
    func toString() -> String {
        return self.description
    }

    var boolValue: Bool {
        return self
    }
}

extension Float: JavaScriptObject {
    func toString() -> String {
        return self.description
    }

    var boolValue: Bool {
        return self != 0
    }
}
