//
//  StringExtension.swift
//  Stocky
//
//  Created by Ankit Singh on 05/10/21.
//

import Foundation

extension String {
    
    func addBrackets() -> String {
        
        return "(\(self))"
    }
    
    func prefix(withText text : String) -> String {
        return text + self
    }
    
}
