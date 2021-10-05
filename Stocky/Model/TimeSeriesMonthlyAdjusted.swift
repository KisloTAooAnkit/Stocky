//
//  TimeSeriesMonthlyAdjusted.swift
//  Stocky
//
//  Created by Ankit Singh on 04/10/21.
//

import Foundation


struct MonthInfo {
    let date : Date
    let adjustedClose : Double
    let adjustedOpen : Double
}



struct TimeSeriesMonthlyAdjusted : Codable{
    
    let meta : Meta
    let timeSeries : [String:OHLC]
    enum CodingKeys : String , CodingKey {
        case meta = "Meta Data"
        case timeSeries = "Monthly Adjusted Time Series"
    }
    
    func getMonthInfos() -> [MonthInfo] {
        var monthInfos : [MonthInfo] = []
        let sortedTimeSeries = timeSeries.sorted(by: {$0.key > $1.key})
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        sortedTimeSeries.forEach { (dateString: String, ohlc: OHLC) in
            let date = dateFormatter.date(from: dateString)!
            let monthInfo = MonthInfo(date: date, adjustedClose:Double(ohlc.adjustedClose)! , adjustedOpen: getAdjustedOpen(ohlc: ohlc))
            monthInfos.append(monthInfo)
        
        }
        return monthInfos
    }
    
    
    private func getAdjustedOpen(ohlc:OHLC) -> Double{
        let adjustedOpen = Double(ohlc.open)! * (Double(ohlc.adjustedClose)!/Double(ohlc.close)!)
        return adjustedOpen
    }
    
}

struct Meta : Codable{
    let symbol : String
    enum CodingKeys : String , CodingKey {
        case symbol = "2. Symbol"
    }
}

struct OHLC : Codable {
    let open : String
    let close : String
    let adjustedClose : String
    
    enum CodingKeys : String , CodingKey {
        case open = "1. open"
        case close = "4. close"
        case adjustedClose = "5. adjusted close"
        
    }
}
