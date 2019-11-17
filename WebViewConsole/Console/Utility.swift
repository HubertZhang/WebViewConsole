//
//  Utility.swift
//  WebViewConsole
//
//  Created by Hubert Zhang on 2019/11/11.
//

import Foundation

func encodeToJson(object: Any) -> String? {
    do {
        if #available(iOS 13.0, *) {
            let d = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .fragmentsAllowed, .withoutEscapingSlashes])
            return String(data: d, encoding: .utf8)
        } else {
            let d = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .fragmentsAllowed])
            return String(data: d, encoding: .utf8)
        }
    } catch let e {
        debugPrint(e)
        return nil
    }
}

func encodeToBase64(string: String) -> String {
    return string.data(using: .utf8)?.base64EncodedString() ?? ""
}
