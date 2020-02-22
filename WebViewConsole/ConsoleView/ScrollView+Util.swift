//
//  ScrollView+Util.swift
//  WebViewConsoleView
//
//  Created by Hubert Zhang on 2019/10/24.
//

import UIKit

extension UIScrollView {
//    func isTopVisible() -> Bool {
//        return true
//    }

    func isBottomVisible() -> Bool {
        if #available(iOS 11.0, *) {
            return self.contentOffset.y + self.bounds.size.height - self.adjustedContentInset.bottom >= self.contentSize.height
        } else {
            return self.contentOffset.y + self.bounds.size.height - self.contentInset.bottom >= self.contentSize.height
        }
    }
}
