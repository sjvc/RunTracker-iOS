//
//  UILabel+html.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 11/03/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func set(html: String) {
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(self.font!.pointSize)\">%@</span>", html)

        let attrStr = try! NSAttributedString(
            data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue],
            documentAttributes: nil)

        self.attributedText = attrStr
    }
}
