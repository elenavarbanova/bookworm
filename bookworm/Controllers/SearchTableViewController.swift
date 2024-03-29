//
//  SearchResultsTableViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 29.01.23.
//

import UIKit
import Alamofire
import AlamofireImage

class SearchTableViewController: UITableViewController {

    let searchController = UISearchController(searchResultsController: nil)
    var items = [Displayable]()
    var currentSearchRequest: DataRequest? = nil
    let backgroundViewLabel = UILabel(frame: .zero)
    let activityIndicator = UIActivityIndicatorView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        setupSearchBar()
        setupTableViewBackgroundView()
    }
    
    func setupSearchBar() {
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search any Book..."
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
    
    func setupTableViewBackgroundView() {
        backgroundViewLabel.textColor = .darkGray
        backgroundViewLabel.numberOfLines = 0
        backgroundViewLabel.text = "Start typing to display search results..."
        backgroundViewLabel.textAlignment = NSTextAlignment.center
        tableView.backgroundView = backgroundViewLabel
    }
    
    func setupTableViewBackgroundViewSearching() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        tableView.backgroundView = activityIndicator
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let book = self.items[indexPath.row]
        
        performSegue(withIdentifier: "DetailBookSegue", sender: book)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "DetailBookSegue",
              let destination = segue.destination as? DetailBookTableViewController,
              let book = sender as? Displayable else {
            return
        }
        
        destination.book = book
        destination.imageID = book.image
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookTableViewCell
        
        let eachBook = items[indexPath.row]
        cell.bookTitleLabel?.text = eachBook.titleLabelText
        cell.authorLabel?.text = eachBook.subtitleLabelText
        cell.bookCoverImage.image = UIImage(systemName: "book.closed")
        if let imageID = eachBook.image {
            cell.imageID = imageID
            let request = AF.request(imageID, method: .get)
            request.responseImage { response in
                if let image = response.value {
                    DispatchQueue.main.async {
                        if cell.imageID == imageID {
                            cell.bookCoverImage.image = image
                        }
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}

extension SearchTableViewController: UISearchBarDelegate {
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
        
        setupTableViewBackgroundViewSearching()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let searchString = searchText.replacingOccurrences(of: " ", with: "+")
        let request = AF.request("https://openlibrary.org/search.json?q=\(searchString)")
        
        currentSearchRequest = request
        
        request
            .validate()
            .responseDecodable(of: ResultBooks.self, decoder: decoder) { [weak self] response in
                guard response.error == nil else { return }
                guard let books = response.value else { return }
                
                self?.activityIndicator.stopAnimating()
                self?.items = books.resultBooks
                self?.tableView.reloadData()
                self?.backgroundViewLabel.isHidden = true
            }
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        items.removeAll()
        tableView.reloadData()
        tableView.backgroundView = backgroundViewLabel
        backgroundViewLabel.isHidden = false
    }
}
