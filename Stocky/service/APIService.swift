//
//  APIService.swift
//  Stocky
//
//  Created by Ankit Singh on 28/09/21.
//

import Foundation
import Combine

struct APIService {

    
    func fetchSymbolsPublisher(keywords : String) -> AnyPublisher<SearchResults,Error> {
        
        let urlString : String = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keywords)&apikey=\(Keys.API_KEY)"
        
        let url = URL(string: urlString)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({$0.data})
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
           
     
        
    }
    
}
