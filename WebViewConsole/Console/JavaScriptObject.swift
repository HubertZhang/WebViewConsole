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

protocol JavaScriptObject: CustomStringConvertible {
    var boolValue: Bool { get }
}

class _JavaScriptUndefined: JavaScriptObject {
    var description: String {
        return "<undefined>"
    }

    var boolValue: Bool {
        return false
    }
}

class _JavaScriptNull: JavaScriptObject {
    var description: String {
        return "<null>"
    }

    var boolValue: Bool {
        return false
    }
}

let JavaScriptUndefined = _JavaScriptUndefined()
let JavaScriptNull = _JavaScriptNull()

extension NSNull: NativeJavaScriptObject {
    func convert() -> JavaScriptObject {
        return JavaScriptNull
    }
}

extension NSDate: NativeJavaScriptObject {
    func convert() -> JavaScriptObject {
        return self as Date
    }
}

extension Date: JavaScriptObject {
    var boolValue: Bool {
        return true
    }
}

extension Array: JavaScriptObject where Element == JavaScriptObject {
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

extension String: JavaScriptObject {
    var boolValue: Bool {
        return self != ""
    }
}

extension NSString: NativeJavaScriptObject {
    func convert() -> JavaScriptObject {
        return self as String
    }
}

extension Dictionary: JavaScriptObject where Key == String, Value == JavaScriptObject {
    var boolValue: Bool {
        return true
    }
}

extension NSDictionary: NativeJavaScriptObject {
    func convert() -> JavaScriptObject {
        if let type = self["__type"] {
            guard let type = type as? String else {
                return JavaScriptNull
            }
            if type == "undefined" {
                return JavaScriptUndefined
            }
            guard let value = self["__value"] else {
                return JavaScriptNull
            }
            switch type {
            case "bigint":
                return (value as! NSNumber).int64Value
            case "boolean":
                return (value as! NSNumber).boolValue
            case "number":
                return (value as! NSNumber).floatValue
            default:
                return JavaScriptNull
            }
        } else {
            var newDict = [String: JavaScriptObject]()
            for key in self.allKeys {
                guard let key = key as? String else {
                    continue
                }
                guard let value = self[key] as? NativeJavaScriptObject else {
                    continue
                }
                newDict[key] = value.convert()
            }
            return newDict
        }
    }

}

extension Int64: JavaScriptObject {
    var boolValue: Bool {
        return self != 0
    }
}

extension Bool: JavaScriptObject {
    var boolValue: Bool {
        return self
    }
}

extension Float: JavaScriptObject {
    var boolValue: Bool {
        return self != 0
    }
}

extension NSNumber: NativeJavaScriptObject {
    func convert() -> JavaScriptObject {
        return JavaScriptNull
    }
}

//func convert(jsObject: NativeJavaScriptObject) -> String {
//    switch jsObject {
//    case is NSNull:
//        return "null"
//    case let string as NSString:
//        return string as String
//    case let date as NSDate:
//        return date.description
//    case let array as NSArray:
//        guard let array = array as? [NativeJavaScriptObject] else {
//            return ""
//        }
//        return "[\(array.map(convert).joined(separator: ", "))]"
//    case let object as Dictionary<String, NativeJavaScriptObject>:
//        if let type = object["__type"] {
//            guard let type = type as? String else {
//                return "[Unknown Type]"
//            }
//            if type == "undefined" {
//                return "undefined"
//            }
//            guard let value = object["__value"] else {
//                return "[Empty Type]"
//            }
//            switch type {
//            case "bigint":
//                return "\((value as! NSNumber).int64Value)"
//            case "boolean":
//                return (value as! NSNumber).boolValue ? "true" : "false"
//            case "number":
//                return (value as! NSNumber).floatValue.description
//            default:
//                return "[Unknown Type]"
//            }
//        } else {
//            let kv =  object.map { (key: String, value: NativeJavaScriptObject) -> String in
//                return "\"\(key)\": \(convert(jsObject: value))"
//            }.joined(separator: ", ")
//            return "{\(kv)}"
//        }
//    default:
//        return ""
//    }
//
//}
//
