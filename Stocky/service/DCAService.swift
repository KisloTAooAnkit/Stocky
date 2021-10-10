//
//  DCAService.swift
//  Stocky
//
//  Created by Ankit Singh on 09/10/21.
//

import Foundation

struct DCAService {
    
    
    func calculate(
        asset : Asset,
        initialInvestmentAmount : Double,
        monthlyDollarCostAveragingAmount : Double,
        initialDateOfInvestmentIndex : Int
        
    ) -> DCAResult {
        
        let investmentAmount  = getInvestmentAmount(initialInvestmentAmount: initialInvestmentAmount, monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount, initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        
        
        let latestSharePrice  = getLatestSharePrice(asset: asset)
        
        let numberOfShares = getNumberOfShares(asset: asset,
                                               initialInvestmentAmount: initialInvestmentAmount,
                                               monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                               initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        
        let currentValue = getCurrentValue(numberOfShares: numberOfShares  , latestSharePrice: latestSharePrice )
        
        let isProfitable = currentValue > investmentAmount
        
        let gain = currentValue - investmentAmount
        
        let yield = gain / investmentAmount
        
        let annualReturn = getAnnualReturn(currenValue: currentValue, investmentAmount: investmentAmount, initialDateOfInvestmentIndex: Double(initialDateOfInvestmentIndex))
        
        return .init(
            
            currentValue: currentValue,
            investmentAmount: investmentAmount,
            gain: gain,
            yield: yield,
            annualReturn: annualReturn,
            isProfitable: isProfitable
        )
    }
    
    
    private func getAnnualReturn(currenValue : Double,investmentAmount : Double,initialDateOfInvestmentIndex : Double) -> Double {
        
        let rate = currenValue/investmentAmount
        
        let years = (initialDateOfInvestmentIndex + 1)/12
        
        return (pow(rate,(1/years)) - 1)
        
    }
    
    private func getInvestmentAmount(initialInvestmentAmount : Double,monthlyDollarCostAveragingAmount : Double,initialDateOfInvestmentIndex : Int) -> Double{
        
        var totalAmount = Double()
        
        totalAmount += initialInvestmentAmount
        
        let dollarCostAveragingAmount = initialDateOfInvestmentIndex.doubleValue * monthlyDollarCostAveragingAmount
        
        totalAmount += dollarCostAveragingAmount
        
        return totalAmount
    }
    
    private func getCurrentValue(numberOfShares : Double , latestSharePrice : Double) -> Double {
        return numberOfShares * latestSharePrice
    }
    
    
    private func getLatestSharePrice(asset : Asset ) -> Double {
        let latestPrice  = asset.timeSeriesMonthlyAdjusted.getMonthInfos().first?.adjustedClose ?? 0
        return latestPrice
    }
    
    private func getNumberOfShares(
        asset : Asset,
        initialInvestmentAmount : Double,
        monthlyDollarCostAveragingAmount : Double,
        initialDateOfInvestmentIndex : Int
    ) -> Double {
        
        var totalShares = Double()
        
        let initialInvestmentOpenPrice = asset.timeSeriesMonthlyAdjusted.getMonthInfos()[initialDateOfInvestmentIndex].adjustedOpen
        
        let initialInvestmentShares = initialInvestmentAmount / initialInvestmentOpenPrice
        
        totalShares += initialInvestmentShares
        asset.timeSeriesMonthlyAdjusted.getMonthInfos().prefix(initialDateOfInvestmentIndex).forEach { monthInfo in
            let dcaInvestmentShares = monthlyDollarCostAveragingAmount/monthInfo.adjustedOpen
            totalShares += dcaInvestmentShares
        }
        
        return totalShares
        
    }
    
    
}

struct DCAResult {
    
    let currentValue : Double
    let investmentAmount : Double
    let gain : Double
    let yield : Double
    let annualReturn : Double
    let isProfitable : Bool
}
