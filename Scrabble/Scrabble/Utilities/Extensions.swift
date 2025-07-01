//
//  Extensions.swift
//  Scrabble
//
//  Created by Eric Johns on 6/30/25.
//

import Foundation

extension Date {
    func toLocalString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        return dateFormatter.string(from: self)
    }
}
