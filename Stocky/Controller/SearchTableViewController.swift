//
//  ViewController.swift
//  Stocky
//
//  Created by Ankit Singh on 28/09/21.
//

import UIKit
import Combine
import MBProgressHUD

class SearchTableViewController: UITableViewController ,UIAnimator  {
    
    
    private enum Mode {
        case onboarding
        case search
    }
    
    private lazy var searchControlller : UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    private var searchResults : SearchResults?
    private let apiService = APIService()
    @Published private var mode = Mode.onboarding
    private var subscriber = Set<AnyCancellable>()
    @Published private var searchQuery = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationBar()
        observeForm()
    }
    
    
    private func observeForm() {
        $searchQuery
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            
            } receiveValue: { [unowned self] value in
                guard !value.isEmpty else {return}
                self.showLoadingAnimation()
                
                print(value)
                self.performSearch(symbol: value)
            }
            .store(in: &subscriber)
        
        $mode.sink { _ in
            
        } receiveValue: {[unowned self] mode in
            switch mode{
            case .search:
                self.tableView.backgroundView = nil
                
            case .onboarding:
                self.tableView.backgroundView = SearchPlaceHolderView()
                
            }
        }
        .store(in: &subscriber)

    }
    
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchControlller
        navigationItem.title = "Search"
    }
    
    private func performSearch(symbol : String) {
        apiService.fetchSymbolsPublisher(keywords: symbol)
            .sink { completion in
                self.hideLoadingAnimation()
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { searchResults in
                
                print(searchResults)
                self.searchResults = searchResults
                self.tableView.reloadData()
                self.tableView.isScrollEnabled = true
            }
            .store(in: &subscriber)

    }
    
    private func setupTableView(){
        tableView.isScrollEnabled = false
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId",for: indexPath) as! SearchTableViewCell
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items[indexPath.row]
            cell.configure(with: searchResult)

        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchResults = searchResults {
            // why item ? instead of indexPath.row ?
            let symbol = searchResults.items[indexPath.item].symbol
            let searchRes = searchResults.items[indexPath.item]
            handleSelection(for: symbol,searchResult: searchRes)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func handleSelection(for symbol : String,searchResult :SearchResult) {
        
        showLoadingAnimation()
        apiService.fetchTimeSeriesMonthlyAdjustedPublisher(keywords: symbol)
            .sink { [weak self] completion in
                self?.hideLoadingAnimation()
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { timeSeriesMonthlyAdjusted in
                self.hideLoadingAnimation()
                let asset = Asset(searchResult: searchResult, timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
                self.performSegue(withIdentifier: "showCalculator", sender: asset)
                self.searchControlller.searchBar.text = nil
            }.store(in: &subscriber)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCalculator",
           let destisnation = segue.destination as? CalculatorTableViewController,
           let asset = sender as? Asset {
            
            destisnation.asset = asset
            
        }
    }
}

extension SearchTableViewController : UISearchResultsUpdating , UISearchControllerDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text , !searchQuery.isEmpty else {
            return
        }
        self.searchQuery = searchQuery
    }
    func willPresentSearchController(_ searchController: UISearchController) {
        self.mode = .search

    }
    
}
