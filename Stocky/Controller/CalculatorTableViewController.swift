//
//  CalculatorTableViewController.swift
//  Stocky
//
//  Created by Ankit Singh on 05/10/21.
//

import UIKit
import Combine

class CalculatorTableViewController: UITableViewController {
    
    
    @IBOutlet weak var currentValueLabel: UILabel!
    
    @IBOutlet weak var investmentAmountLabel: UILabel!
    
    @IBOutlet weak var gainLabel: UILabel!
    
    @IBOutlet weak var yieldLabel: UILabel!
    
    @IBOutlet weak var annualReturnLabel: UILabel!
    
    
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBOutlet weak var assetNameLabel: UILabel!
    
    @IBOutlet var currencyLabel: [UILabel]!
    
    @IBOutlet weak var investmentAmountCurrLabel: UILabel!
    
    @IBOutlet weak var initialInvestmentAmountTextField : UITextField!
    
    @IBOutlet weak var monthlyDollarCostAveragingTextField : UITextField!
    
    @IBOutlet weak var initialDateOfInvestmentTextField : UITextField!
    
    @IBOutlet weak var dateSlider : UISlider!
    
    @Published private var initialDateOfInvestmentIndex : Int?
    @Published private var initialInvestmentAmount : Int?
    @Published private var monthlyDollarCostAveragingAmount : Int?
    
    var subscribers = Set<AnyCancellable>()
    var asset : Asset?
    private let dcaService = DCAService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTextFields()
        observeForm()
        setupDateSlider()
        resetViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initialInvestmentAmountTextField.becomeFirstResponder()
    }
    
    private func setupDateSlider() {
        if let count = asset?.timeSeriesMonthlyAdjusted.getMonthInfos().count{
            print("maxsliderValue",count.floatvalue)
            dateSlider.maximumValue = count.floatvalue - 1
        }
    }
    
    
    private func setupViews() {
        symbolLabel.text = asset?.searchResult.symbol
        assetNameLabel.text = asset?.searchResult.name
        investmentAmountCurrLabel.text = asset?.searchResult.currency
        currencyLabel.forEach { label in
            label.text = asset?.searchResult.currency.addBrackets()
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDateSelection"{
            if let dateSelectionViewController = segue.destination as? DateSelectionTableViewController , let timeSeriesMonthlyAdjusted = sender as? TimeSeriesMonthlyAdjusted{
                dateSelectionViewController.timeSeriesMonthlyAdjusted = timeSeriesMonthlyAdjusted
                dateSelectionViewController.didSelectDate = { [weak self] index in
                    self?.handleDateSelection(at: index)
                    dateSelectionViewController.selectedIndex = self?.initialDateOfInvestmentIndex
                }
            }
        }
    }
    
    private func handleDateSelection(at index :Int){
        
        guard navigationController?.visibleViewController is DateSelectionTableViewController else {return}
        
        navigationController?.popViewController(animated: true)
        
        if let monthInfos = asset?.timeSeriesMonthlyAdjusted.getMonthInfos(){
            initialDateOfInvestmentIndex = index
            let monthInfo = monthInfos[index]
            let dateString = monthInfo.date.MMYYFormat
            
            initialDateOfInvestmentTextField.text = dateString
        }
        
    }
    
    
    private func resetViews() {
        currentValueLabel.text = "0.00"
        investmentAmountLabel.text = "0.00"
        gainLabel.text = "-"
        yieldLabel.text = "-"
        annualReturnLabel.text = "-"
    }
    
    
    @IBAction func dateSliderValueDidChange(_ sender: UISlider) {
        
        initialDateOfInvestmentIndex = Int(sender.value)
    }
    
    private func setupTextFields(){
        initialInvestmentAmountTextField.addDoneButton()
        monthlyDollarCostAveragingTextField.addDoneButton()
        initialDateOfInvestmentTextField.delegate = self
    }
    
    private func observeForm() {
        
        $initialDateOfInvestmentIndex
            .sink { [weak self] index in
                guard let index = index else {return}
                print(index)
                self?.dateSlider.value = index.floatvalue
                
                if let dateString = self?.asset?.timeSeriesMonthlyAdjusted.getMonthInfos()[index].date.MMYYFormat{
                    self?.initialDateOfInvestmentTextField.text = dateString
                }
                
                
            }.store(in: &subscribers)
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: initialInvestmentAmountTextField)
            .compactMap { notification -> String? in
                var text : String?
                if let textField = notification.object as? UITextField {
                    text = textField.text
                }
                return text
            }.sink { [weak self] text in
                self?.initialInvestmentAmount = Int(text) ?? 0
            }
            .store(in: &subscribers)
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: monthlyDollarCostAveragingTextField)
            .compactMap { notification -> String? in
                var text : String?
                if let textField = notification.object as? UITextField {
                    text = textField.text
                }
                return text
            }.sink { [weak self] text in
                self?.monthlyDollarCostAveragingAmount = Int(text) ?? 0
                
            }
            .store(in: &subscribers)
        
        
        Publishers.CombineLatest3(
            $initialInvestmentAmount,
            $monthlyDollarCostAveragingAmount,
            $initialDateOfInvestmentIndex
        )
            .sink { [weak self] (initialInvestmentAmount,monthlyDollarCostAveragingAmount,initialDateOfInvestmentIndex) in
                //                print("initialInvestmentAmount :\(initialInvestmentAmount) \nmonthlyDollarCostAveragingAmount: \(monthlyDollarCostAveragingAmount) \ninitialDateOfInvestmentIndex:\(initialDateOfInvestmentIndex)")
                
                
                guard let initialInvestmentAmount = initialInvestmentAmount ,
                      let monthlyDollarCostAveragingAmount = monthlyDollarCostAveragingAmount,
                      let initialDateOfInvestmentIndex = initialDateOfInvestmentIndex,
                      let asset = self?.asset else { return }
                
                
                let result = self?.dcaService.calculate(
                    
                    asset: asset,
                    initialInvestmentAmount: initialInvestmentAmount.doubleValue,
                    monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount.doubleValue,
                    initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
                
                
                let isProfitable = result?.isProfitable == true
                let gainSymbol = isProfitable ? "+" : ""
                
                self?.currentValueLabel.backgroundColor = isProfitable ? .themeGreenShade : .themeRedShade
                self?.currentValueLabel.text = result?.currentValue.currencyFormat
                self?.investmentAmountLabel.text = result?.investmentAmount.toCurrencyFormat( hasDecimalPlaces: false)
                self?.gainLabel.text = result?.gain.toCurrencyFormat(hasDollarSymbol: false, hasDecimalPlaces: false).prefix(withText: gainSymbol)
                self?.yieldLabel.text = result?.yield.percentageFormat.prefix(withText: gainSymbol).addBrackets()
                self?.yieldLabel.textColor = isProfitable ? .systemGreen : .systemRed
                self?.annualReturnLabel.text = result?.annualReturn.percentageFormat
                self?.annualReturnLabel.textColor = isProfitable ? .systemGreen : .systemRed
                
                
                
            }.store(in: &subscribers)
        
        
        
    }
    
}

extension CalculatorTableViewController : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == initialDateOfInvestmentTextField {
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted)
            return false
        }
        
        return true
    }
    
}
