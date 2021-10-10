//
//  DateSelectionTableViewController.swift
//  Stocky
//
//  Created by Ankit Singh on 07/10/21.
//

import UIKit

class DateSelectionTableViewController : UITableViewController {
    
    
    var timeSeriesMonthlyAdjusted : TimeSeriesMonthlyAdjusted?
    
    var selectedIndex : Int?
    
    private var monthInfos : [MonthInfo] = []
    
    var didSelectDate: ((Int) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigation()
    
    }
    
    private func setupNavigation(){
        title = "Select date"
        
    }
    
    
    private func setupViews() {
        monthInfos = timeSeriesMonthlyAdjusted?.getMonthInfos() ?? []
    }
    
    
    
}

extension DateSelectionTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthInfos.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID",for: indexPath) as! DateSelectionTableViewCell
        let monthInfo = monthInfos[indexPath.item]
        let isSelected = indexPath.item == selectedIndex
        cell.configure(with: monthInfo,index: indexPath.item, isSelected: isSelected)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectDate?(indexPath.item)
        selectedIndex = indexPath.item
        tableView.reloadData()
    }
    
}


class DateSelectionTableViewCell : UITableViewCell{
    
    
    @IBOutlet weak var monthLabel : UILabel!
    @IBOutlet weak var monthsAgoLabel : UILabel!
    
    
    func configure(with monthInfo : MonthInfo , index : Int,isSelected:Bool){
        
        accessoryType = isSelected ? .checkmark : .none
        
        monthLabel.text = monthInfo.date.MMYYFormat
        switch index {
        case 1:
            monthsAgoLabel.text = "1 month ago"
        case 0:
            monthsAgoLabel.text = "Just invested"
        default:
            monthsAgoLabel.text = "\(index) months ago"
        }
    }
    
    
}
