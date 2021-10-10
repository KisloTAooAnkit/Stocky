//
//  DateExtension.swift
//  Stocky
//
//  Created by Ankit Singh on 07/10/21.
//

import Foundation

extension Date {
    var MMYYFormat : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }
}
