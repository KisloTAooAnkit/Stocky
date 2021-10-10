//
//  DoubtExtensions.swift
//  Stocky
//
//  Created by Ankit Singh on 09/10/21.
//

import Foundation

extension Double {
    var stringValue : String
    {
        return String(describing: self)
    }
    
    var twoDecimalPlaceString : String {
        return String(format: "%.2f", self)
    }
    
    
    var currencyFormat : String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if let value = formatter.string(from: self as NSNumber){
            return value
        }
        return twoDecimalPlaceString
    }
    
    
    func toCurrencyFormat(hasDollarSymbol : Bool = true,hasDecimalPlaces : Bool = true) -> String{
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if !hasDollarSymbol{
            formatter.currencySymbol = ""
        }
        if !hasDecimalPlaces {
            formatter.maximumFractionDigits = 0
        }
        if let value = formatter.string(from: self as NSNumber){
            return value
        }
        return twoDecimalPlaceString
        
    }
    
    
    var percentageFormat : String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        if let value = formatter.string(from: self as NSNumber){
            return value
        }
        return twoDecimalPlaceString
    }

    
}
