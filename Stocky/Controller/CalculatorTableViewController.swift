//
//  CalculatorTableViewController.swift
//  Stocky
//
//  Created by Ankit Singh on 05/10/21.
//

import UIKit

class CalculatorTableViewController: UITableViewController {
    
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBOutlet weak var assetNameLabel: UILabel!
    
    @IBOutlet var currencyLabel: [UILabel]!
    
    @IBOutlet weak var investmentAmountCurrLabel: UILabel!
    
    var asset : Asset?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    
    private func setupViews() {
        symbolLabel.text = asset?.searchResult.symbol
        assetNameLabel.text = asset?.searchResult.name
        investmentAmountCurrLabel.text = asset?.searchResult.currency
        currencyLabel.forEach { label in
            label.text = asset?.searchResult.currency.addBrackets()

        }
        
    }
}
