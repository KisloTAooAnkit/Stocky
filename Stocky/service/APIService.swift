//
//  APIService.swift
//  Stocky
//
//  Created by Ankit Singh on 28/09/21.
//

import Foundation
import Combine




struct APIService {

    
    
    enum APIServiceError : Error {
        case encoding
        case badRequest
    }
    
    func fetchSymbolsPublisher(keywords : String) -> AnyPublisher<SearchResults,Error> {
        
        
        let queryResult = parseQueryString(text: keywords)
        var symbol : String = ""

        switch queryResult {
        case .success(let query):
            symbol = query
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        

        
        let urlString : String = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(symbol)&apikey=\(Keys.API_KEY)"
        
        let urlResult = parseURL(urlString: urlString)
        
        switch urlResult {
        case .success(let url):
            return URLSession.shared.dataTaskPublisher(for: url)
                .map({$0.data})
                .decode(type: SearchResults.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func fetchTimeSeriesMonthlyAdjustedPublisher(keywords : String) -> AnyPublisher<TimeSeriesMonthlyAdjusted,Error>{
        
        
        
        let queryResult = parseQueryString(text: keywords)
        
        var symbol : String = ""
        
        switch queryResult {
        case .success(let query):
            symbol = query
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
        

        
        let urlString : String = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=\(symbol)&apikey=\(Keys.API_KEY)"
        
        let urlResult = parseURL(urlString: urlString)
        
        switch urlResult {
        case .success(let url):
            return URLSession.shared.dataTaskPublisher(for: url)
                .map({$0.data})
                .decode(type: TimeSeriesMonthlyAdjusted.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        

        
    }
    
    private func parseQueryString (text : String) -> Result<String,Error> {
        
        if let query = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        {
            return .success(query)
        }
        else{
            return .failure(APIServiceError.encoding)
        }

    }
    
    
    private func parseURL(urlString : String) -> Result<URL,Error>
    {
        if let url = URL(string: urlString){
            return .success(url)
        }
        else {
            return .failure(APIServiceError.badRequest)
        }
    }
    
}
