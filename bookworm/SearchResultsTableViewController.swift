//
//  SearchResultsTableViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 29.01.23.
//

import UIKit
import Alamofire
import AlamofireImage

class SearchResultsTableViewController: UITableViewController {

    let searchController = UISearchController(searchResultsController: nil)
    var items = [Displayable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableViewBackgroundView()
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        fetchResultBooks(for: searchText)
        sender.endRefreshing()
        self.tableView.reloadData()
    }
    
    func setupSearchBar() {
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search any Book..."
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
    

    
    func setupTableViewBackgroundView() {
        let backgroundViewLabel = UILabel(frame: .zero)
        backgroundViewLabel.textColor = .darkGray
        backgroundViewLabel.numberOfLines = 0
        backgroundViewLabel.text = "Oops, No results to show!"
        backgroundViewLabel.textAlignment = NSTextAlignment.center
        tableView.backgroundView = backgroundViewLabel
    }
    
    

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultBookCell", for: indexPath) as! ResultBookTableViewCell
        
        let eachBook = items[indexPath.row]
        cell.bookTitleLabel?.text = eachBook.titleLabelText
        cell.authorLabel?.text = eachBook.subtitleLabelText
        
        if let imageID = eachBook.image {
            cell.imageID = imageID
            let request = AF.request(imageID, method: .get)
            request.responseImage { response in
                guard let image = response.value else {
                    return
                }
                DispatchQueue.main.async {
                    if cell.imageID == imageID {
                        cell.bookCoverImage.image = image
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    
    var currentSearchRequest: DataRequest? = nil
}

extension SearchResultsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        items.removeAll()

        guard let textToSearch = searchBar.text, !textToSearch.isEmpty else {
            return
        }
        fetchResultBooks(for: textToSearch)
    }
    
    
    func fetchResultBooks(for searchText: String) {
        currentSearchRequest?.cancel()
        currentSearchRequest = nil
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let searchString = searchText.replacingOccurrences(of: " ", with: "+")
        let request = AF.request("https://openlibrary.org/search.json?q=\(searchString)")
        
        currentSearchRequest = request
        
        request
            .validate()
            .responseDecodable(of: ResultBooks.self, decoder: decoder) { response in
                guard response.error == nil else { return }
                guard let books = response.value else { return }
                
                self.items = books.resultBooks
                self.tableView.reloadData()
            }
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        items.removeAll()
        self.tableView.reloadData()
    }
}