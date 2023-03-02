//
//  HomeViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 9.01.23.
//

import UIKit
import Alamofire
import AlamofireImage

class HomeTableViewController: UITableViewController {
    
    var items = [Displayable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTrendingBooks()
        setupTableViewBackgroundView()
    }
    
    func setupTableViewBackgroundView() {
        let activityIndicator = UIActivityIndicatorView(frame: .zero)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        tableView.backgroundView = activityIndicator
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        fetchTrendingBooks()
        sender.endRefreshing()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let book = self.items[indexPath.row]
        
        performSegue(withIdentifier: "DetailBookSegue", sender: book)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookTableViewCell
        
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
}

extension HomeTableViewController {
    func fetchTrendingBooks() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let request = AF.request("https://openlibrary.org/trending/daily.json")
        request
            .validate()
            .responseDecodable(of: Books.self, decoder: decoder) { response in
                guard let books = response.value else { return }
                
                self.items = books.allBooks
                self.tableView.reloadData()
            }
    }
}
